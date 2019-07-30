# frozen_string_literal: true

module Ciao
  module Renderers
    class Base
      def initialize(_template, _data)
        raise NotImplementedError,
              'You can not initiate an instance of Ciao::Renderers::Base'
      end

      def render
        raise NotImplementedError,
              'You can not call Ciao::Renderers::Base#render directly'
      end
    end
  end
end
