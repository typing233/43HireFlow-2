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
        render json: {
          user: UserCompactSerializer.new(resource).as_json,
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
  end
end
