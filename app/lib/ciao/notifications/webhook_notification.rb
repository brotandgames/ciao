# frozen_string_literal: true

module Ciao
  module Notifications
    class WebhookNotification < Base
      def notify(payload_data = {})
        notify!(payload_data)
      rescue *NET_HTTP_ERRORS, WebhookError => e
        Rails.logger.error "Ciao::Notifications::WebhookNotification#notify Could not notify webhook(#{@endpoint}) - #{e}"
      end

      # Like #notify, but raises on connection errors and non-2xx responses
      def notify!(payload_data = {})
        uri = URI.parse(@endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"

        request = Net::HTTP::Post.new(
          uri.request_uri,
          "Content-Type" => "application/json"
        )
        request.body = @payload_renderer.render(payload_data)
        response = http.request(request)
        raise WebhookError, "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        response
      end
    end

    class WebhookError < StandardError; end
  end
end
