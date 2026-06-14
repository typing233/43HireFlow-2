module Api
  module V1
    class TeamMembersController < BaseController
      def index
        authorize @current_team, :show?
        members = @current_team.team_memberships.includes(:user)
        render json: members, each_serializer: TeamMemberSerializer
      end

      def update
        authorize @current_team, :manage_members?
        membership = @current_team.team_memberships.find(params[:id])

        if membership.role == "owner" && !current_user.owner_of?(@current_team)
          render_error "Cannot modify owner role", status: :forbidden
          return
        end

        if membership.update(role: params[:role])
          render json: membership, serializer: TeamMemberSerializer
        else
          render_error membership
        end
      end

      def destroy
        authorize @current_team, :manage_members?
        membership = @current_team.team_memberships.find(params[:id])

        if membership.role == "owner"
          render_error "Cannot remove team owner", status: :forbidden
          return
        end

        membership.destroy!
        head :no_content
      end
    end
  end
end
