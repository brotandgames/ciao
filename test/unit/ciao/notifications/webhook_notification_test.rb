# frozen_string_literal: true

require 'test_helper'

module Ciao
  module Notifications
    class WebhookNotificationTest < ActiveSupport::TestCase
      test '#initialize assigns @endpoint & @payload_renderer' do
        notification = Ciao::Notifications::WebhookNotification.new(
          'https://foo.bar',
          '{"foo": "bar"}',
          Ciao::Renderers::ReplaceRenderer
        )
        assert_equal 'https://foo.bar',
                     notification.instance_variable_get(:@endpoint)
        assert_instance_of Ciao::Renderers::ReplaceRenderer,
                           notification.instance_variable_get(:@payload_renderer)
      end

      test '#notify' do
        stub_request(:post, 'https://foo.bar/').with(
          body: '{"name": "bar"}',
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: '{"status":"success"}', headers: {})

        notification = Ciao::Notifications::WebhookNotification.new(
          'https://foo.bar',
          '{"name": "__check_name__"}',
          Ciao::Renderers::ReplaceRenderer
        )
        response = notification.notify(name: 'bar')
        assert_equal '{"status":"success"}', response.body
        assert_equal '200', response.code
      end
    end
  end
end
