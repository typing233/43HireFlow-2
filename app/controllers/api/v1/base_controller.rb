module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_user!
      before_action :set_current_team

      include Pagy::Backend

      private

      def set_current_team
        @current_team = current_user.teams.find(params[:team_id] || current_user.team_memberships.first&.team_id)
        ActsAsTenant.current_tenant = @current_team
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Team not found or access denied" }, status: :forbidden
      end

      def current_membership
        @current_membership ||= current_user.team_memberships.find_by(team: @current_team)
      end

      def render_paginated(collection, serializer: nil)
        pagy, records = pagy(collection, items: params.fetch(:per_page, 25).to_i)
        response.headers["X-Total-Count"] = pagy.count.to_s
        response.headers["X-Page"] = pagy.page.to_s
        response.headers["X-Per-Page"] = pagy.items.to_s

        if serializer
          render json: records, each_serializer: serializer
        else
          render json: records
        end
      end

      def render_error(record_or_message, status: :unprocessable_entity)
        if record_or_message.is_a?(ActiveRecord::Base)
          render json: { errors: record_or_message.errors.full_messages }, status: status
        else
          render json: { error: record_or_message }, status: status
        end
      end

      def render_success(data, status: :ok)
        render json: data, status: status
      end
    end
  end
end
