# frozen_string_literal: true

require "test_helper"

module Ciao
  module Parsers
    class WebhookParserTest < ActiveSupport::TestCase
      def with_env(vars)
        vars.each { |k, v| ENV[k] = v }
        yield
      ensure
        vars.each_key { |k| ENV.delete(k) }
      end

      # -- .matches ------------------------------------------------------------

      test ".matches returns empty array when no webhook env vars are set" do
        assert_equal [], Ciao::Parsers::WebhookParser.matches
      end

      test ".matches returns match objects for CIAO_WEBHOOK_ENDPOINT_ vars" do
        with_env("CIAO_WEBHOOK_ENDPOINT_SLACK" => "https://hooks.slack.com/xxx") do
          assert_equal 1, Ciao::Parsers::WebhookParser.matches.size
          assert_equal "SLACK", Ciao::Parsers::WebhookParser.matches.first[:name]
        end
      end

      test ".matches ignores CIAO_WEBHOOK_PAYLOAD_ vars" do
        with_env("CIAO_WEBHOOK_PAYLOAD_SLACK" => "payload") do
          assert_equal [], Ciao::Parsers::WebhookParser.matches
        end
      end

      test ".matches ignores CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_ vars" do
        with_env("CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_SLACK" => "tls-payload") do
          assert_equal [], Ciao::Parsers::WebhookParser.matches
        end
      end

      # -- .names --------------------------------------------------------------

      test ".names returns empty array when no webhook env vars are set" do
        assert_equal [], Ciao::Parsers::WebhookParser.names
      end

      test ".names extracts the webhook name from the env var" do
        with_env("CIAO_WEBHOOK_ENDPOINT_SLACK" => "https://hooks.slack.com/xxx") do
          assert_equal ["SLACK"], Ciao::Parsers::WebhookParser.names
        end
      end

      test ".names returns multiple names when multiple webhooks are configured" do
        with_env(
          "CIAO_WEBHOOK_ENDPOINT_SLACK" => "https://hooks.slack.com/xxx",
          "CIAO_WEBHOOK_ENDPOINT_TEAMS" => "https://outlook.office.com/webhook/xxx"
        ) do
          names = Ciao::Parsers::WebhookParser.names
          assert_equal 2, names.size
          assert_includes names, "SLACK"
          assert_includes names, "TEAMS"
        end
      end

      # -- .webhooks -----------------------------------------------------------

      test ".webhooks returns empty array when no webhook env vars are set" do
        assert_equal [], Ciao::Parsers::WebhookParser.webhooks
      end

      test ".webhooks returns endpoint, payload and tls payload" do
        with_env(
          "CIAO_WEBHOOK_ENDPOINT_SLACK" => "https://hooks.slack.com/xxx",
          "CIAO_WEBHOOK_PAYLOAD_SLACK" => '{"text":"__name__ changed"}',
          "CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_SLACK" => '{"text":"TLS expires in __tls_expires_in_days__ days"}'
        ) do
          webhooks = Ciao::Parsers::WebhookParser.webhooks
          assert_equal 1, webhooks.size
          assert_equal "https://hooks.slack.com/xxx", webhooks.first[:endpoint]
          assert_equal '{"text":"__name__ changed"}', webhooks.first[:payload]
          assert_equal '{"text":"TLS expires in __tls_expires_in_days__ days"}', webhooks.first[:payload_tls_expires]
        end
      end

      test ".webhooks defaults payload and tls_payload to empty string when not configured" do
        with_env("CIAO_WEBHOOK_ENDPOINT_TEST" => "https://example.com/hook") do
          webhook = Ciao::Parsers::WebhookParser.webhooks.first
          assert_equal "", webhook[:payload]
          assert_equal "", webhook[:payload_tls_expires]
        end
      end
    end
  end
end
