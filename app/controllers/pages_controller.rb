class PagesController < ApplicationController
  def home
    render json: { message: "HireFlow ATS API", version: "1.0.0" }
  end
end
