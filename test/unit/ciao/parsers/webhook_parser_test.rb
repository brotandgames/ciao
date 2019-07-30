# frozen_string_literal: true

require 'test_helper'

module Ciao
  module Parsers
    class WebhookParserTest < ActiveSupport::TestCase
      test 'self.matches' do
        ENV['CIAO_WEBHOOK_ENDPOINT_1'] = 'https://foo.bar'
        assert_equal '1', Ciao::Parsers::WebhookParser.matches.first[:name]
      end

      test 'self.names' do
        Ciao::Parsers::WebhookParser.expects(:matches).returns([stub(:[] => '1')])
        assert_equal ['1'], Ciao::Parsers::WebhookParser.names
      end

      test 'self.webhooks' do
        ENV['CIAO_WEBHOOK_ENDPOINT_1'] = 'https://foo.bar'
        ENV['CIAO_WEBHOOK_PAYLOAD_1'] = '{"foo":"bar"}'
        assert_equal [{
          endpoint: 'https://foo.bar',
          payload: '{"foo":"bar"}'
        }], Ciao::Parsers::WebhookParser.webhooks
      end
    end
  end
end
