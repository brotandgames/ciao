# frozen_string_literal: true

module Ciao
  module Renderers
    class ReplaceRenderer < Base
      CHECK_NAME_PLACEHOLDER = '__check_name__'
      STATUS_AFTER_PLACEHOLDER = '__status_after__'
      STATUS_BEFORE_PLACEHOLDER = '__status_before__'

      def render(data)
        @template
          .gsub(CHECK_NAME_PLACEHOLDER, data.fetch(:name, '').to_s)
          .gsub(STATUS_AFTER_PLACEHOLDER, data.fetch(:status_before, '').to_s)
          .gsub(STATUS_BEFORE_PLACEHOLDER, data.fetch(:status_after, '').to_s)
      end
    end
  end
end
