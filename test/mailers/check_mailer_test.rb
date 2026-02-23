# frozen_string_literal: true

require "test_helper"

class CheckMailerTest < ActionMailer::TestCase
  test "change_status_mail has correct subject" do
    mail = CheckMailer.with(
      name: "My Check",
      url: "https://example.com",
      status_before: "200",
      status_after: "500"
    ).change_status_mail

    assert_equal "[ciao] My Check: Status changed (500)", mail.subject
  end

  test "change_status_mail is delivered to configured recipient" do
    mail = CheckMailer.with(
      name: "My Check",
      url: "https://example.com",
      status_before: "200",
      status_after: "500"
    ).change_status_mail

    assert_emails 1 do
      mail.deliver_now
    end
  end

  test "tls_expires_mail has correct subject" do
    mail = CheckMailer.with(
      name: "My Check",
      url: "https://example.com",
      tls_expires_at: Time.now + 10.days,
      tls_expires_in_days: 10
    ).tls_expires_mail

    assert_equal "[ciao] My Check: TLS certificate expires in 10 days", mail.subject
  end

  test "tls_expires_mail is delivered" do
    mail = CheckMailer.with(
      name: "My Check",
      url: "https://example.com",
      tls_expires_at: Time.now + 10.days,
      tls_expires_in_days: 10
    ).tls_expires_mail

    assert_emails 1 do
      mail.deliver_now
    end
  end
end
