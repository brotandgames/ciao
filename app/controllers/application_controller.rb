# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate
  protect_from_forgery unless: -> { request.format.json? }

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
