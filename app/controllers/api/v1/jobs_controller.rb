module Api
  module V1
    class JobsController < BaseController
      before_action :set_job, only: [:show, :update, :destroy, :publish, :close, :archive, :restore]

      def index
        authorize Job
        jobs = policy_scope(Job).includes(:creator, :stages)
        jobs = jobs.where(status: params[:status]) if params[:status].present?
        render_paginated jobs, serializer: JobSerializer
      end

      def show
        authorize @job
        render json: @job, serializer: JobDetailSerializer
      end

      def create
        authorize Job
        @job = @current_team.jobs.build(job_params)
        @job.creator = current_user

        if @job.save
          Seeds::DefaultStages.create_for(@job)
          log_activity(@job, "job.created")
          render json: @job, serializer: JobDetailSerializer, status: :created
        else
          render_error @job
        end
      end

      def update
        authorize @job
        if @job.update(job_params)
          log_activity(@job, "job.updated", changes_snapshot: @job.previous_changes)
          render json: @job, serializer: JobDetailSerializer
        else
          render_error @job
        end
      end

      def destroy
        authorize @job
        @job.destroy!
        log_activity(@job, "job.deleted")
        head :no_content
      end

      def publish
        authorize @job, :publish?
        if @job.may_publish?
          @job.publish!
          log_activity(@job, "job.published")
          render json: @job, serializer: JobDetailSerializer
        else
          render_error "Job cannot be published from current state", status: :unprocessable_entity
        end
      end

      def close
        authorize @job, :close?
        if @job.may_close?
          @job.close!
          log_activity(@job, "job.closed")
          render json: @job, serializer: JobDetailSerializer
        else
          render_error "Job cannot be closed from current state", status: :unprocessable_entity
        end
      end

      def archive
        authorize @job, :archive?
        if @job.may_archive?
          @job.archive!
          log_activity(@job, "job.archived")
          render json: @job, serializer: JobDetailSerializer
        else
          render_error "Job cannot be archived from current state", status: :unprocessable_entity
        end
      end

      def restore
        authorize @job, :restore?
        if @job.may_restore?
          @job.restore!
          log_activity(@job, "job.restored")
          render json: @job, serializer: JobDetailSerializer
        else
          render_error "Job cannot be restored from current state", status: :unprocessable_entity
        end
      end

      private

      def set_job
        @job = @current_team.jobs.find(params[:id])
      end

      def job_params
        params.require(:job).permit(:title, :description, :department, :location, :employment_type)
      end

      def log_activity(job, action, changes_snapshot: {})
        ActivityLog.record!(
          team: @current_team,
          user: current_user,
          trackable: job,
          action: action,
          changes_snapshot: changes_snapshot
        )
      end
    end
  end
end
