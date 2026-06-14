class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def show
    checks = {
      database: database_connected?,
      redis: redis_connected?,
      sidekiq: sidekiq_running?
    }

    status = checks.values.all? ? :ok : :service_unavailable
    render json: { status: status == :ok ? "healthy" : "unhealthy", checks: checks }, status: status
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def redis_connected?
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping == "PONG"
  rescue StandardError
    false
  end

  def sidekiq_running?
    Sidekiq::ProcessSet.new.size > 0
  rescue StandardError
    false
  end
end
