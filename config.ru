# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

prometheus_enabled = ENV.fetch('PROMETHEUS_ENABLED', 'false')

if prometheus_enabled == 'true'
  require 'prometheus/middleware/collector'

  rackapp = Rack::Builder.app do
    use Prometheus::Middleware::Collector
    if ENV['PROMETHEUS_BASIC_AUTH_USERNAME'].present?
      map '/metrics' do
        use Rack::Auth::Basic, 'Ciao Prometheus Metrics' do |username, password|
          Rack::Utils.secure_compare(ENV['PROMETHEUS_BASIC_AUTH_USERNAME'], username) &&
            Rack::Utils.secure_compare(ENV['PROMETHEUS_BASIC_AUTH_PASSWORD'], password)
        end
        use Rack::Deflater
        use Yabeda::Prometheus::Exporter, path: ''
        run ->(_) { [500, { 'Content-Type' => 'text/html' }, ['Ciao Prometheus Metrics unreachable.']] }
      end
    else
      use Yabeda::Prometheus::Exporter
    end
    run Rails.application
  end
  run rackapp
else
  run Rails.application
end
