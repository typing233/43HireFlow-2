source "https://rubygems.org"

ruby "3.2.2"

gem "rails", "~> 7.1.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "redis", "~> 5.0"
gem "sidekiq", "~> 7.2"
gem "devise", "~> 4.9"
gem "devise_invitable", "~> 2.0"
gem "pundit", "~> 2.3"
gem "acts_as_tenant", "~> 1.0"
gem "aasm", "~> 5.5"
gem "paper_trail", "~> 15.1"
gem "active_model_serializers", "~> 0.10"
gem "rack-cors", "~> 2.0"
gem "pagy", "~> 6.2"
gem "active_storage_validations", "~> 1.1"
gem "image_processing", "~> 1.12"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]
gem "jbuilder", "~> 2.11"

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "pry-rails"
  gem "dotenv-rails"
  gem "shoulda-matchers", "~> 5.3"
  gem "database_cleaner-active_record", "~> 2.1"
end

group :development do
  gem "annotate"
  gem "bullet"
  gem "brakeman"
  gem "rubocop-rails", require: false
end

group :test do
  gem "simplecov", require: false
  gem "webmock"
  gem "timecop"
end
