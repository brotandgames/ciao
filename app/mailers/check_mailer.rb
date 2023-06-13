# frozen_string_literal: true

# Mailer to send mails about checkhealth updates/changes.
# `From:`, `To:` and other SMTP options are configured at config/environments/production.rb
class CheckMailer < ApplicationMailer
  # Sends mail to inform the receiver about a
  # healthcheck status change
  # @param name [String] the name of the healthcheck
  # @param status_before [String] the old status, `1XX..5XX` or `e`
  # @param status_after [String] the new status, `1XX..5XX` or `e`
  def change_status_mail
    @name = params[:name]
    @status_before = params[:status_before]
    @status_after = params[:status_after]
    mail(subject: "[ciao] #{@name}: Status changed (#{@status_after})")
  end

  # Sends mail to inform the receiver about a
  # expiration of TLS certificate
  # @param name [String] the name of the healthcheck
  # @param tls_expires_at [DateTime] DateTime when the TLS certificate expires
  # @param tls_expires_in_days [Integer] Days until the TLS certificate expires
  def tls_expires_mail
    @name = params[:name]
    @tls_expires_at = params[:tls_expires_at]
    @tls_expires_in_days = params[:tls_expires_in_days]
    mail(subject: "[ciao] #{@name}: TLS certificate expires in (#{@tls_expires_in_days})")
  end
end
