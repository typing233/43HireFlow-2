module Api
  module V1
    class CandidatesController < BaseController
      before_action :set_job
      before_action :set_candidate, only: [:show, :update, :destroy, :move_stage]

      def index
        authorize Candidate
        candidates = policy_scope(@job.candidates).includes(:stage)
        candidates = candidates.in_stage(params[:stage_id]) if params[:stage_id].present?
        render_paginated candidates, serializer: CandidateSerializer
      end

      def show
        authorize @candidate
        render json: @candidate, serializer: CandidateDetailSerializer
      end

      def create
        authorize Candidate
        @candidate = @job.candidates.build(candidate_params)
        @candidate.team = @current_team
        @candidate.stage = @job.current_stages.first unless @candidate.stage_id
        @candidate.pipeline_version = @job.pipeline_version

        if @candidate.save
          log_activity(@candidate, "candidate.created")
          render json: @candidate, serializer: CandidateDetailSerializer, status: :created
        else
          render_error @candidate
        end
      end

      def update
        authorize @candidate
        if @candidate.update(candidate_params)
          log_activity(@candidate, "candidate.updated", changes_snapshot: @candidate.previous_changes)
          render json: @candidate, serializer: CandidateDetailSerializer
        else
          render_error @candidate
        end
      end

      def destroy
        authorize @candidate
        @candidate.destroy!
        log_activity(@candidate, "candidate.deleted")
        head :no_content
      end

      def move_stage
        authorize @candidate, :move_stage?
        new_stage = @job.current_stages.find(params[:stage_id])
        expected_lock_version = params[:lock_version].to_i

        if @candidate.lock_version != expected_lock_version
          render json: {
            error: "Conflict",
            message: "Candidate was modified by another user. Please refresh.",
            current_lock_version: @candidate.lock_version
          }, status: :conflict
          return
        end

        @candidate.move_to_stage!(new_stage, moved_by: current_user)
        render json: @candidate.reload, serializer: CandidateDetailSerializer
      rescue ActiveRecord::StaleObjectError
        render json: {
          error: "Conflict",
          message: "Candidate was modified by another user. Please refresh.",
          current_lock_version: @candidate.reload.lock_version
        }, status: :conflict
      end

      def batch_move
        authorize Candidate, :batch_move?
        new_stage = @job.current_stages.find(params[:stage_id])
        candidate_ids = params[:candidate_ids]

        # Only allow IDs that belong to this job AND this team
        valid_ids = @job.candidates.where(team: @current_team, id: candidate_ids).pluck(:id)

        if valid_ids.empty?
          render_error "No valid candidates found", status: :unprocessable_entity
          return
        end

        BatchMoveCandidatesJob.perform_later(
          candidate_ids: valid_ids,
          stage_id: new_stage.id,
          moved_by_id: current_user.id,
          team_id: @current_team.id,
          job_id: @job.id
        )

        render json: { message: "Batch move queued", candidate_count: valid_ids.size }, status: :accepted
      end

      private

      def set_job
        @job = @current_team.jobs.find(params[:job_id])
      end

      def set_candidate
        @candidate = @job.candidates.find(params[:id])
      end

      def candidate_params
        params.require(:candidate).permit(
          :first_name, :last_name, :email, :phone,
          :source, :stage_id, :lock_version,
          custom_fields: {}
        )
      end

      def log_activity(candidate, action, changes_snapshot: {})
        ActivityLog.record!(
          team: @current_team,
          user: current_user,
          trackable: candidate,
          action: action,
          changes_snapshot: changes_snapshot
        )
      end
    end
  end
end
