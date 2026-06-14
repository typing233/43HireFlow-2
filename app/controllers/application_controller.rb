class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::StaleObjectError, with: :conflict_error

  private

  def user_not_authorized
    respond_to do |format|
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
      format.html { redirect_to root_path, alert: "You are not authorized." }
    end
  end

  def not_found
    respond_to do |format|
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.html { redirect_to root_path, alert: "Resource not found." }
    end
  end

  def conflict_error
    respond_to do |format|
      format.json do
        render json: {
          error: "Conflict",
          message: "This record has been modified by another user. Please refresh and try again."
        }, status: :conflict
      end
      format.html { redirect_back fallback_location: root_path, alert: "Conflict detected." }
    end
  end
end
