# frozen_string_literal: true

module Ciao
  module Parsers
    class WebhookParser
      WEBHOOKS_ENDPOINT_PREFIX = 'CIAO_WEBHOOK_ENDPOINT_'
      WEBHOOKS_PAYLOAD_PREFIX = 'CIAO_WEBHOOK_PAYLOAD_'

      WEBHOOKS_PAYLOAD_FORMAT = "#{WEBHOOKS_PAYLOAD_PREFIX}%d"
      WEBHOOKS_ENDPOINT_FORMAT = "#{WEBHOOKS_ENDPOINT_PREFIX}%d"

      WEBHOOKS_FORMAT_REGEX = /^#{WEBHOOKS_ENDPOINT_PREFIX}(?<sequence>[0-9]+)$/.freeze

      # rubocop:disable Style/ClassVars
      def self.webhooks
        @@sequences ||= sequences.map do |sequence|
          {
            endpoint: ENV.fetch(WEBHOOKS_ENDPOINT_FORMAT % sequence, ''),
            payload: ENV.fetch(WEBHOOKS_PAYLOAD_FORMAT % sequence, '')
          }
        end
      end
      # rubocop:enable Style/ClassVars

      def self.sequences
        matches.map { |match| match[:sequence] }
      end

      def self.matches
        ENV.map do |k, _v|
          k.match(WEBHOOKS_FORMAT_REGEX)
        end.compact
      end
    end
  end
end
