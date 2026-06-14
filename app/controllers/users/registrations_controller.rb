module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      build_resource(sign_up_params)

      resource.save
      if resource.persisted?
        team = Team.create!(name: "#{resource.first_name}'s Team")
        TeamMembership.create!(user: resource, team: team, role: "owner")

        sign_up(resource_name, resource)
        render json: {
          user: UserCompactSerializer.new(resource).as_json,
          team: TeamSerializer.new(team).as_json,
          message: "Signed up successfully."
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
  end
end
