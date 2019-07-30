# frozen_string_literal: true

require 'test_helper'

module Ciao
  module Renderers
    class ReplaceRendererTest < ActiveSupport::TestCase
      test '#initialize assigns @template' do
        renderer = ReplaceRenderer.new('{"name": "__name__"}')
        assert_equal '{"name": "__name__"}',
                     renderer.instance_variable_get(:@template)
      end

      test '#render replaces webhook placeholders' do
        renderer = ReplaceRenderer.new(
          '{"name": "__name__", "status_after":"__status_after__", "status_before":"__status_before__"}'
        )
        assert_equal '{"name": "foo", "status_after":"500", "status_before":"200"}',
                     renderer.render(name: 'foo', status_after: '500', status_before: '200')
      end
    end
  end
end
