# frozen_string_literal: true

require "test_helper"

module Ciao
  module Notifications
    class WebhookNotificationTest < ActiveSupport::TestCase
      test "#initialize assigns @endpoint & @payload_renderer" do
        notification = Ciao::Notifications::WebhookNotification.new(
          "https://foo.bar",
          '{"foo": "bar"}',
          Ciao::Renderers::ReplaceRenderer
        )
        assert_equal "https://foo.bar",
          notification.instance_variable_get(:@endpoint)
        assert_instance_of Ciao::Renderers::ReplaceRenderer,
          notification.instance_variable_get(:@payload_renderer)
      end

      test "#notify" do
        stub_request(:post, "https://foo.bar/").with(
          body: '{"name": "bar"}',
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "User-Agent" => "Ruby"
          }
        ).to_return(status: 200, body: '{"status":"success"}', headers: {})

        notification = Ciao::Notifications::WebhookNotification.new(
          "https://foo.bar",
          '{"name": "__name__"}',
          Ciao::Renderers::ReplaceRenderer
        )
        response = notification.notify(name: "bar")
        assert_equal '{"status":"success"}', response.body
        assert_equal "200", response.code
      end

      test "#notify logs and does not raise on non-2xx responses" do
        stub_request(:post, "https://foo.bar/").to_return(status: 404)
        notification = Ciao::Notifications::WebhookNotification.new("https://foo.bar", "{}")
        Rails.logger.expects(:error).with(includes("HTTP 404")).once
        assert_nothing_raised { notification.notify(name: "bar") }
      end

      test "#notify logs and does not raise on connection errors" do
        stub_request(:post, "https://foo.bar/").to_raise(Errno::ECONNREFUSED)
        notification = Ciao::Notifications::WebhookNotification.new("https://foo.bar", "{}")
        Rails.logger.expects(:error).once
        assert_nothing_raised { notification.notify(name: "bar") }
      end

      test "#notify! returns the response on 2xx" do
        stub_request(:post, "https://foo.bar/").to_return(status: 204)
        notification = Ciao::Notifications::WebhookNotification.new("https://foo.bar", "{}")
        assert_equal "204", notification.notify!(name: "bar").code
      end

      test "#notify! raises on non-2xx responses" do
        stub_request(:post, "https://foo.bar/").to_return(status: 500)
        notification = Ciao::Notifications::WebhookNotification.new("https://foo.bar", "{}")
        error = assert_raises(Ciao::Notifications::WebhookError) { notification.notify!(name: "bar") }
        assert_equal "HTTP 500", error.message
      end

      test "#notify! raises on connection errors" do
        stub_request(:post, "https://foo.bar/").to_raise(Errno::ECONNREFUSED)
        notification = Ciao::Notifications::WebhookNotification.new("https://foo.bar", "{}")
        assert_raises(Errno::ECONNREFUSED) { notification.notify!(name: "bar") }
      end
    end
  end
end
