# frozen_string_literal: true

module Ciao
  module Renderers
    class ReplaceRenderer < Base
      CHECK_NAME_PLACEHOLDER = '__name__'
      STATUS_AFTER_PLACEHOLDER = '__status_after__'
      STATUS_BEFORE_PLACEHOLDER = '__status_before__'
      URL_PLACEHOLDER = '__url__'
      CHECK_URL_PLACEHOLDER = '__check_url__'

      def render(data)
        return '' if @template.nil?

        @template
          .gsub(CHECK_NAME_PLACEHOLDER, data.fetch(:name, '').to_s)
          .gsub(STATUS_AFTER_PLACEHOLDER, data.fetch(:status_after, '').to_s)
          .gsub(STATUS_BEFORE_PLACEHOLDER, data.fetch(:status_before, '').to_s)
          .gsub(URL_PLACEHOLDER, data.fetch(:url, '').to_s)
          .gsub(CHECK_URL_PLACEHOLDER, data.fetch(:check_url, '').to_s)
      end
    end
  end
end
