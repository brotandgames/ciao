# frozen_string_literal: true

module Ciao
  module Notifications
    class WebhookNotification < Base
      def initialize(endpoint,
                     payload_template,
                     payload_renderer = Ciao::Renderers::MustacheRenderer)
        @endpoint = endpoint
        @payload_renderer = payload_renderer.new(payload_template)
      end

      def notify(payload_data)
        uri = URI.parse(@endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'

        request = Net::HTTP::Post.new(
          uri.request_uri,
          'Content-Type' => 'application/json'
        )
        request.body = @payload_renderer.render(payload_data)
        http.request(request)
      end
    end
  end
end
