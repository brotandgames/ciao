# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ciao
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # ciao does not use Active Storage image variants
    config.active_storage.variant_processor = :disabled

    # Default time_zone is UTC
    ENV["TIME_ZONE"] ||= "UTC"
    config.time_zone = ENV["TIME_ZONE"]
  end
end
