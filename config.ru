# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

ENV['PROMETHEUS_ENABLED'] ||= 'false'

if ENV['PROMETHEUS_ENABLED'] == 'true'
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'

  rackapp = Rack::Builder.app do
    # rubocop:disable Metrics/LineLength
    use Prometheus::Middleware::Collector
    if ENV['PROMETHEUS_BASIC_AUTH_USERNAME'].present?
      map '/metrics' do
        use Rack::Auth::Basic, 'Ciao Prometheus Metrics' do |username, password|
          Rack::Utils.secure_compare(ENV['PROMETHEUS_BASIC_AUTH_USERNAME'], username) &&
            Rack::Utils.secure_compare(ENV['PROMETHEUS_BASIC_AUTH_PASSWORD'], password)
        end
        use Rack::Deflater
        use Prometheus::Middleware::Exporter, path: ''
        run ->(_) { [500, { 'Content-Type' => 'text/html' }, ['Ciao Prometheus Metrics unreachable.']] }
      end
    else
      use Prometheus::Middleware::Exporter
    end
    run Rails.application
    # rubocop:enable Metrics/LineLength
  end
  run rackapp
else
  run Rails.application
end
