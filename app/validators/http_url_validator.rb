# frozen_string_literal: true

class HttpUrlValidator < ActiveModel::EachValidator
  def self.compliant?(value)
    escaped_address = URI.escape(value)
    uri = URI.parse(escaped_address)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    return if value.present? && self.class.compliant?(value)

    record.errors.add(attribute, 'is not a valid HTTP URL')
  end
end
