# frozen_string_literal: true

module Ciao
  module Notifications
    class Base
      def initialize(endpoint = nil,
        payload_template = nil,
        payload_renderer_cls = Ciao::Renderers::ReplaceRenderer)
        @endpoint = endpoint
        @payload_renderer = payload_renderer_cls.new(payload_template)
      end

      def notify(_payload_data = {})
        raise NotImplementedError,
          "You can not call Ciao::Notifications::Base#notify directly"
      end

      # Sends the notification and raises on failure (used by test notifications).
      # Subclasses whose #notify swallows errors should override this.
      def notify!(payload_data = {})
        notify(payload_data)
      end
    end
  end
end
