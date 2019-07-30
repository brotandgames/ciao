# frozen_string_literal: true

module Ciao
  module Notifications
    class MailNotification < Base
      def notify(payload_data = {})
        CheckMailer.with(payload_data).change_status_mail.deliver
      end
    end
  end
end
