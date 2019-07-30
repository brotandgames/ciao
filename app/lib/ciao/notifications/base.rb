# frozen_string_literal: true

module Ciao
  module Notifications
    class Base
      def initialize(_endpoint, _payload)
        raise NotImplementedError,
              'You can not initiate an instance of Ciao::Notifications::Base'
      end

      def notify
        raise NotImplementedError,
              'You can not call Ciao::Notifications::Base#notiy directly'
      end
    end
  end
end
