module Api
  module V1
    class AttachmentsController < BaseController
      before_action :set_job
      before_action :set_candidate

      def index
        authorize Attachment
        attachments = @candidate.attachments.includes(:user)
        render json: attachments, each_serializer: AttachmentSerializer
      end

      def create
        authorize Attachment
        @attachment = @candidate.attachments.build(attachment_params)
        @attachment.user = current_user
        @attachment.team = @current_team
        @attachment.file_name = params[:attachment][:file]&.original_filename || "unnamed"

        if @attachment.save
          log_activity(@candidate, "attachment.created")
          render json: @attachment, serializer: AttachmentSerializer, status: :created
        else
          render_error @attachment
        end
      end

      def destroy
        authorize Attachment
        attachment = @candidate.attachments.find(params[:id])
        attachment.destroy!
        head :no_content
      end

      private

      def set_job
        @job = @current_team.jobs.find(params[:job_id])
      end

      def set_candidate
        @candidate = @job.candidates.find(params[:candidate_id])
      end

      def attachment_params
        params.require(:attachment).permit(:file, :category)
      end

      def log_activity(candidate, action)
        ActivityLog.record!(
          team: @current_team,
          user: current_user,
          trackable: candidate,
          action: action
        )
      end
    end
  end
end
