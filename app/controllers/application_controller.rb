class ApplicationController < ActionController::Base
  before_action :authenticate
  protect_from_forgery unless: -> { request.format.json? }

  def authenticate
    # rubocop:disable Metrics/LineLength
    basic_auth_username = ENV.fetch('BASIC_AUTH_USERNAME', '')
    basic_auth_password = ENV.fetch('BASIC_AUTH_PASSWORD', '')

    return true if basic_auth_username.empty?

    authenticate_or_request_with_http_basic('Ciao Application') do |username, password|
      username == basic_auth_username && password == basic_auth_password
    end
    # rubocop:enable Metrics/LineLength
  end
end
