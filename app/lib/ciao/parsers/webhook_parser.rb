# frozen_string_literal: true

module Ciao
  module Parsers
    class WebhookParser
      WEBHOOKS_ENDPOINT_PREFIX = 'CIAO_WEBHOOK_ENDPOINT_'
      WEBHOOKS_PAYLOAD_PREFIX = 'CIAO_WEBHOOK_PAYLOAD_'

      WEBHOOKS_PAYLOAD_FORMAT = "#{WEBHOOKS_PAYLOAD_PREFIX}%s"
      WEBHOOKS_ENDPOINT_FORMAT = "#{WEBHOOKS_ENDPOINT_PREFIX}%s"

      WEBHOOKS_FORMAT_REGEX = /^#{WEBHOOKS_ENDPOINT_PREFIX}(?<name>[A-Z0-9_]+)$/.freeze

      # rubocop:disable Style/ClassVars
      def self.webhooks
        @@names ||= names.map do |name|
          {
            endpoint: ENV.fetch(WEBHOOKS_ENDPOINT_FORMAT % name, ''),
            payload: ENV.fetch(WEBHOOKS_PAYLOAD_FORMAT % name, '')
          }
        end
      end
      # rubocop:enable Style/ClassVars

      def self.names
        matches.map { |match| match[:name] }
      end

      def self.matches
        ENV.map do |k, _v|
          k.match(WEBHOOKS_FORMAT_REGEX)
        end.compact
      end
    end
  end
end
