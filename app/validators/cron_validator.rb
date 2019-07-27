# frozen_string_literal: true

class CronValidator < ActiveModel::EachValidator
  def self.compliant?(value)
    cron = ::Fugit::Cron.parse(value)
    cron.present?
  rescue StandardError => e
    Rails.logger.info "CronValidator Exception: #{e}"
    false
  end

  def validate_each(record, attribute, value)
    return if value.present? && self.class.compliant?(value)

    record.errors.add(attribute, 'is not a valid cron. Check your cron schedule expression here: https://crontab.guru')
  end
end
