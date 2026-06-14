module Api
  module V1
    class ActivityLogsController < BaseController
      def index
        authorize ActivityLog
        logs = @current_team.activity_logs.chronological.includes(:user, :trackable)
        logs = logs.where(trackable_type: params[:trackable_type]) if params[:trackable_type].present?
        logs = logs.where(trackable_id: params[:trackable_id]) if params[:trackable_id].present?
        logs = logs.where(action: params[:action]) if params[:action].present?
        render_paginated logs, serializer: ActivityLogSerializer
      end
    end
  end
end
