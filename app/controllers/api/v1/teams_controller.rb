module Api
  module V1
    class TeamsController < BaseController
      def show
        authorize @current_team
        render json: @current_team, serializer: TeamSerializer
      end

      def update
        authorize @current_team
        if @current_team.update(team_params)
          render json: @current_team, serializer: TeamSerializer
        else
          render_error @current_team
        end
      end

      def invite_member
        authorize @current_team, :invite_member?
        email = params[:email]
        role = params[:role] || "member"

        user = User.find_by(email: email)
        if user
          membership = @current_team.team_memberships.find_or_initialize_by(user: user)
          membership.role = role
          if membership.save
            render json: { message: "Member added" }, status: :created
          else
            render_error membership
          end
        else
          invited_user = User.invite!({ email: email, invited_team_id: @current_team.id }, current_user)
          @current_team.team_memberships.create!(user: invited_user, role: role)
          render json: { message: "Invitation sent" }, status: :created
        end
      end

      private

      def team_params
        params.require(:team).permit(:name, :description, settings: {})
      end
    end
  end
end
