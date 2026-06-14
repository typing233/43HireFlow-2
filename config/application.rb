require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module HireFlow
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :sidekiq

    config.time_zone = "UTC"

    config.api_only = false

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.orm :active_record, primary_key_type: :uuid
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "/api/*",
          headers: :any,
          methods: %i[get post put patch delete options head],
          expose: %w[X-Total-Count X-Page X-Per-Page]
      end
    end
  end
end
