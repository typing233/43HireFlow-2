module Api
  module V1
    class NotesController < BaseController
      before_action :set_job
      before_action :set_candidate
      before_action :set_note, only: [:update, :destroy]

      def index
        authorize Note
        notes = @candidate.notes.visible_to(current_user).chronological.includes(:user)
        render json: notes, each_serializer: NoteSerializer
      end

      def create
        authorize Note
        @note = @candidate.notes.build(note_params)
        @note.user = current_user

        if @note.save
          log_activity(@candidate, "note.created")
          render json: @note, serializer: NoteSerializer, status: :created
        else
          render_error @note
        end
      end

      def update
        authorize @note
        if @note.update(note_params)
          render json: @note, serializer: NoteSerializer
        else
          render_error @note
        end
      end

      def destroy
        authorize @note
        @note.destroy!
        head :no_content
      end

      private

      def set_job
        @job = @current_team.jobs.find(params[:job_id])
      end

      def set_candidate
        @candidate = @job.candidates.find(params[:candidate_id])
      end

      def set_note
        @note = @candidate.notes.find(params[:id])
      end

      def note_params
        params.require(:note).permit(:body, :private)
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
