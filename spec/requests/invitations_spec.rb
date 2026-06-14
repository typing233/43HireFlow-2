require "rails_helper"

RSpec.describe "Team Invitations", type: :request do
  let(:team) { create(:team) }
  let(:admin) { create(:user) }
  let!(:admin_membership) { create(:team_membership, user: admin, team: team, role: "owner") }

  before { sign_in admin }

  describe "POST /api/v1/teams/:id/invite_member" do
    context "inviting a new user" do
      it "creates invitation and team membership" do
        post "/api/v1/teams/#{team.id}/invite_member",
             params: { team_id: team.id, email: "newuser@example.com", role: "recruiter" }

        expect(response).to have_http_status(:created)
        invited_user = User.find_by(email: "newuser@example.com")
        expect(invited_user).to be_present
        expect(invited_user.invited_team_id).to eq(team.id)
        expect(invited_user.team_memberships.find_by(team: team).role).to eq("recruiter")
      end
    end

    context "inviting an existing user" do
      let(:existing_user) { create(:user) }

      it "adds existing user to team" do
        post "/api/v1/teams/#{team.id}/invite_member",
             params: { team_id: team.id, email: existing_user.email, role: "member" }

        expect(response).to have_http_status(:created)
        expect(existing_user.reload.member_of?(team)).to be true
      end
    end
  end

  describe "accepting an invitation" do
    it "ensures team membership exists after acceptance" do
      # Invite user
      post "/api/v1/teams/#{team.id}/invite_member",
           params: { team_id: team.id, email: "invited@example.com", role: "hiring_manager" }

      invited_user = User.find_by(email: "invited@example.com")
      token = invited_user.raw_invitation_token

      sign_out admin

      # Accept invitation
      put "/users/invitation",
          params: {
            invitation_token: token,
            password: "newpassword123",
            password_confirmation: "newpassword123",
            first_name: "Invited",
            last_name: "User"
          }

      invited_user.reload
      expect(invited_user.invitation_accepted_at).to be_present
      expect(invited_user.member_of?(team)).to be true
      expect(invited_user.role_in(team)).to eq("hiring_manager")
    end
  end
end
