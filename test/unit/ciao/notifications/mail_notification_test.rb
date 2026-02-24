# frozen_string_literal: true

require "test_helper"

module Ciao
  module Notifications
    class BaseTest < ActiveSupport::TestCase
      test "#notify raises NotImplementedError" do
        base = Ciao::Notifications::Base.new
        assert_raises(NotImplementedError) { base.notify }
      end
    end

    class MailNotificationTest < ActiveSupport::TestCase
      test "#notify delivers change_status_mail" do
        notification = Ciao::Notifications::MailNotification.new

        message = mock
        message.expects(:deliver)
        CheckMailer.expects(:with).returns(stub(change_status_mail: message))

        notification.notify(name: "Test", status_before: "200", status_after: "500")
      end

      test "#notify for TLS delivers tls_expires_mail" do
        notification = Ciao::Notifications::MailNotificationTlsExpires.new

        message = mock
        message.expects(:deliver)
        CheckMailer.expects(:with).returns(stub(tls_expires_mail: message))

        notification.notify(name: "Test", tls_expires_in_days: 10)
      end
    end
  end
end
