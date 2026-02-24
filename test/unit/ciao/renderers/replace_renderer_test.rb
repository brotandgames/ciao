# frozen_string_literal: true

require "test_helper"

module Ciao
  module Renderers
    class BaseTest < ActiveSupport::TestCase
      test "#render raises NotImplementedError" do
        base = Ciao::Renderers::Base.new("template")
        assert_raises(NotImplementedError) { base.render({}) }
      end
    end

    class ReplaceRendererTest < ActiveSupport::TestCase
      test "#initialize assigns @template" do
        renderer = ReplaceRenderer.new('{"name": "__name__"}')
        assert_equal '{"name": "__name__"}',
          renderer.instance_variable_get(:@template)
      end

      test "#render returns empty string when template is nil" do
        renderer = ReplaceRenderer.new(nil)
        assert_equal "", renderer.render({})
      end

      test "#render returns template unchanged when it contains no placeholders" do
        renderer = ReplaceRenderer.new("hello world")
        assert_equal "hello world", renderer.render({})
      end

      test "#render replaces __name__ placeholder" do
        renderer = ReplaceRenderer.new("Check: __name__")
        assert_equal "Check: My Check", renderer.render(name: "My Check")
      end

      test "#render replaces __status_after__ placeholder" do
        renderer = ReplaceRenderer.new("Status: __status_after__")
        assert_equal "Status: 500", renderer.render(status_after: "500")
      end

      test "#render replaces __status_before__ placeholder" do
        renderer = ReplaceRenderer.new("Was: __status_before__")
        assert_equal "Was: 200", renderer.render(status_before: "200")
      end

      test "#render replaces __url__ placeholder" do
        renderer = ReplaceRenderer.new("URL: __url__")
        assert_equal "URL: https://example.com", renderer.render(url: "https://example.com")
      end

      test "#render replaces __check_url__ placeholder" do
        renderer = ReplaceRenderer.new("Path: __check_url__")
        assert_equal "Path: /checks/1", renderer.render(check_url: "/checks/1")
      end

      test "#render replaces __tls_expires_at__ placeholder" do
        time = Time.new(2026, 6, 1, 12, 0, 0)
        renderer = ReplaceRenderer.new("Expires: __tls_expires_at__")
        assert_equal "Expires: #{time}", renderer.render(tls_expires_at: time)
      end

      test "#render replaces __tls_expires_in_days__ placeholder" do
        renderer = ReplaceRenderer.new("Days: __tls_expires_in_days__")
        assert_equal "Days: 10", renderer.render(tls_expires_in_days: 10)
      end

      test "#render replaces multiple placeholders in a single template" do
        renderer = ReplaceRenderer.new(
          '{"name": "__name__", "status_after":"__status_after__", "status_before":"__status_before__"}'
        )
        assert_equal '{"name": "foo", "status_after":"500", "status_before":"200"}',
          renderer.render(name: "foo", status_after: "500", status_before: "200")
      end

      test "#render uses empty string for placeholder keys not present in data" do
        renderer = ReplaceRenderer.new("__name__: __status_after__")
        assert_equal ": ", renderer.render({})
      end
    end
  end
end
