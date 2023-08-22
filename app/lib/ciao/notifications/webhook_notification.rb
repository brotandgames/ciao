# frozen_string_literal: true

module Ciao
  module Notifications
    class WebhookNotification < Base
      def notify(payload_data = {})
        uri = URI.parse(@endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"

        request = Net::HTTP::Post.new(
          uri.request_uri,
          "Content-Type" => "application/json"
        )
        request.body = @payload_renderer.render(payload_data)
        http.request(request)
      rescue *NET_HTTP_ERRORS => e
        Rails.logger.error "Ciao::Notifications::WebhookNotification#notify Could not notify webhook(#{@endpoint}) - #{e}"
      end
    end
  end
end
