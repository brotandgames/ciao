# frozen_string_literal: true

module ChecksHelper
  # Converts the HTTP status to the corresponding CSS class
  # to control HTML element classes based on HTTP status
  # @param status [Integer] the HTTP response status, `2XX..5XX`
  # @return [String] the CSS class for the corresponding HTTP status
  def class_for_status(status)
    case status.to_i
    when 200..299
      'success'
    when 300..399
      'info'
    when 400..499
      'warning'
    else
      'danger'
    end
  end

  # Converts the healthcheck's active flag to CSS class
  # to control HTML element color
  # @param active [Boolean] the healthcheck's active flag, `true` or `false`
  # @return [String] the corresponding color (CSS class)
  def class_for_active(active)
    active ? 'text-green' : 'text-red'
  end

  # Converts the healthcheck's active flag to CSS class
  # to control checkbox icon
  # @param active [Boolean] the healthcheck's active flag, `true` or `false`
  # @return [String] the corresponding checkbox icon (CSS class)
  def class_for_active_checkbox(active)
    active ? 'fe-check' : 'fe-minus'
  end

  # Converts the healthy percentage to CSS class
  # to control healthy/unhealthy colors
  # @param percent [Float] the healthy percentage
  # @return [String] the corresponding color (CSS class)
  def class_for_healthy(percent)
    percent == 100.0 ? 'text-green' : 'text-red'
  end
end
