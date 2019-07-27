# frozen_string_literal: true

# Mailer to send mails about checkhealth updates/changes.
# `From:`, `To:` and other SMTP options are configured at config/environments/production.rb
class CheckMailer < ApplicationMailer
  # Sends mail to inform the receiver about a
  # healthcheck status change
  # @param name [String] the name of the healthcheck
  # @param status_before [String] the old HTTP status, `2XX..5XX`
  # @param status_after [String] the new HTTP status, `2XX..5XX`
  def change_status_mail
    @name = params[:name]
    @status_before = params[:status_before]
    @status_after = params[:status_after]
    mail(subject: "[ciao] #{@name}: Status changed (#{@status_after})")
  end
end
