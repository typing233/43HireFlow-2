module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      render json: {
        user: UserCompactSerializer.new(resource).as_json,
        message: "Signed in successfully."
      }
    end

    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      render json: { message: "Signed out successfully." }
    end
  end
end
