module Api
  module V1
    class StagesController < BaseController
      before_action :set_job
      before_action :set_stage, only: [:update, :destroy]

      def index
        authorize Stage
        stages = @job.current_stages.ordered
        render json: stages, each_serializer: StageSerializer
      end

      def create
        authorize Stage
        @stage = @job.stages.build(stage_params)
        @stage.pipeline_version = @job.pipeline_version
        @stage.position ||= @job.current_stages.maximum(:position).to_i + 1

        if has_candidates_in_pipeline?
          service = PipelineUpgradeService.new(@job, current_user)
          service.add_stage!(@stage)
          render json: @job.reload.current_stages.ordered, each_serializer: StageSerializer, status: :created
        elsif @stage.save
          log_activity(@stage, "stage.created")
          render json: @job.current_stages.ordered, each_serializer: StageSerializer, status: :created
        else
          render_error @stage
        end
      end

      def update
        authorize @stage
        if has_candidates_in_pipeline?
          service = PipelineUpgradeService.new(@job, current_user)
          service.update_stage!(@stage, stage_params)
          render json: @job.reload.current_stages.ordered, each_serializer: StageSerializer
        elsif @stage.update(stage_params)
          log_activity(@stage, "stage.updated")
          render json: @job.current_stages.ordered, each_serializer: StageSerializer
        else
          render_error @stage
        end
      end

      def destroy
        authorize @stage
        if @stage.candidates.active.any?
          render_error "Cannot delete stage with active candidates", status: :unprocessable_entity
        else
          if has_candidates_in_pipeline?
            service = PipelineUpgradeService.new(@job, current_user)
            service.remove_stage!(@stage)
          else
            @stage.destroy!
          end
          log_activity(@stage, "stage.deleted")
          head :no_content
        end
      end

      def reorder
        authorize Stage, :reorder?

        if has_candidates_in_pipeline?
          stage_positions = params[:stages].map { |s| { id: s[:id], position: s[:position] } }
          service = PipelineUpgradeService.new(@job, current_user)
          service.reorder!(stage_positions)
          render json: @job.reload.current_stages.ordered, each_serializer: StageSerializer
        else
          params[:stages].each do |stage_data|
            stage = @job.current_stages.find(stage_data[:id])
            stage.update!(position: stage_data[:position])
          end
          render json: @job.current_stages.reload.ordered, each_serializer: StageSerializer
        end
      end

      private

      def set_job
        @job = @current_team.jobs.find(params[:job_id])
      end

      def set_stage
        @stage = @job.current_stages.find(params[:id])
      end

      def stage_params
        params.require(:stage).permit(:name, :position, metadata: {})
      end

      def has_candidates_in_pipeline?
        @job.candidates.where(pipeline_version: @job.pipeline_version).exists?
      end

      def log_activity(stage, action)
        ActivityLog.record!(
          team: @current_team,
          user: current_user,
          trackable: stage,
          action: action
        )
      end
    end
  end
end
