# frozen_string_literal: true

module Ciao
  module Renderers
    class Base
      def initialize(template)
        @template = template
      end

      def render(_data)
        raise NotImplementedError,
              'You can not call Ciao::Renderers::Base#render directly'
      end
    end
  end
end
