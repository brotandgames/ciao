# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate
  # Skip CSRF protection only for requests whose body is sent as JSON (REST API).
  # A cross-site HTML form cannot set this Content-Type without a CORS preflight,
  # unlike the format (`.json` extension), which any form can choose.
  protect_from_forgery with: :exception, unless: -> { request.media_type == "application/json" }

  def authenticate
    basic_auth_username = ENV.fetch("BASIC_AUTH_USERNAME", "")
    basic_auth_password = ENV.fetch("BASIC_AUTH_PASSWORD", "")

    return true if basic_auth_username.empty?

    authenticate_or_request_with_http_basic("Ciao Application") do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, basic_auth_username) &&
        ActiveSupport::SecurityUtils.secure_compare(password, basic_auth_password)
    end
  end
end
