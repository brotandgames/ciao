# frozen_string_literal: true

module Ciao
  module Parsers
    class WebhookParser
      WEBHOOKS_ENDPOINT_PREFIX = 'CIAO_WEBHOOK_ENDPOINT_'
      WEBHOOKS_PAYLOAD_PREFIX = 'CIAO_WEBHOOK_PAYLOAD_'
      WEBHOOKS_PAYLOAD_TLS_EXPIRES_PREFIX = 'CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_'

      WEBHOOKS_ENDPOINT_FORMAT = "#{WEBHOOKS_ENDPOINT_PREFIX}%s".freeze
      WEBHOOKS_PAYLOAD_FORMAT = "#{WEBHOOKS_PAYLOAD_PREFIX}%s".freeze
      WEBHOOKS_PAYLOAD_TLS_EXPIRES_FORMAT = "#{WEBHOOKS_PAYLOAD_TLS_EXPIRES_PREFIX}%s".freeze

      WEBHOOKS_FORMAT_REGEX = /^#{WEBHOOKS_ENDPOINT_PREFIX}(?<name>[A-Z0-9_]+)$/

      def self.webhooks
        names.map do |check_name|
          {
            endpoint: ENV.fetch(WEBHOOKS_ENDPOINT_FORMAT % check_name, ''),
            payload: ENV.fetch(WEBHOOKS_PAYLOAD_FORMAT % check_name, ''),
            payload_tls_expires: ENV.fetch(WEBHOOKS_PAYLOAD_TLS_EXPIRES_FORMAT % check_name, '')
          }
        end
      end

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
