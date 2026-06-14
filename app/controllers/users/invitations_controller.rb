module Users
  class InvitationsController < Devise::InvitationsController
    respond_to :json

    def create
      self.resource = invite_resource
      if resource.errors.empty?
        render json: { message: "Invitation sent successfully." }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      raw_invitation_token = update_resource_params[:invitation_token]
      self.resource = accept_resource

      if resource.errors.empty?
        ensure_team_membership!(resource)
        sign_in(resource)
        render json: {
          user: UserCompactSerializer.new(resource).as_json,
          teams: resource.teams.map { |t| TeamSerializer.new(t).as_json },
          message: "Invitation accepted successfully."
        }
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def invite_params
      params.permit(:email, :first_name, :last_name)
    end

    def update_resource_params
      params.permit(:invitation_token, :password, :password_confirmation, :first_name, :last_name)
    end

    def ensure_team_membership!(user)
      # The inviter already created a TeamMembership via TeamsController#invite_member.
      # As a safety net, if the membership was somehow lost, recreate it using
      # the stored invited_team_id.
      return if user.team_memberships.exists?

      team = Team.find_by(id: user.invited_team_id)
      if team
        TeamMembership.create!(user: user, team: team, role: "member")
      else
        # Fallback: use inviter's team
        inviter = user.invited_by
        return unless inviter.is_a?(User)
        fallback_team = inviter.teams.first
        return unless fallback_team
        TeamMembership.create!(user: user, team: fallback_team, role: "member")
      end
    end
  end
end
