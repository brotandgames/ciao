# frozen_string_literal: true

module Ciao
  module Renderers
    class MustacheRenderer < Base
      def initialize(template)
        @template = template
      end

      def render(_data)
        ''
      end
    end
  end
end
