# frozen_string_literal: true

module ChecksHelper
  # Converts the status to the corresponding CSS class
  # to control HTML element classes based on status
  # @param status [String] this is either the HTTP status code or an error, `1XX..5XX` or `e`
  # @return [String] the CSS class for the corresponding HTTP status
  def class_for_status(status)
    case status.to_i
    when 100..199
      "secondary"
    when 200..299
      "success"
    when 300..399
      "info"
    when 400..499
      "warning"
    else
      "danger"
    end
  end

  # Converts the tls_expires_in_days to the corresponding CSS class
  # to control HTML element classes based on tls_expires_in_days
  # @param tls_expires_in_days [Integer] TLS certificate expiration in days
  # @return [String] the CSS class for the corresponding tls_expires_in_days
  def class_for_tls_expires_in_days(tls_expires_in_days)
    case tls_expires_in_days
    when -Float::INFINITY..7
      "text-danger"
    when 8..30
      "text-warning"
    when 31..Float::INFINITY
      "text"
    end
  end

  # Converts the healthcheck's active flag to CSS class
  # to control HTML element color
  # @param active [Boolean] the healthcheck's active flag, `true` or `false`
  # @return [String] the corresponding color (CSS class)
  def class_for_active(active)
    active ? "text-green" : "text-red"
  end

  # Converts the healthcheck's active flag to CSS class
  # to control checkbox icon
  # @param active [Boolean] the healthcheck's active flag, `true` or `false`
  # @return [String] the corresponding checkbox icon (CSS class)
  def class_for_active_checkbox(active)
    active ? "ti-check" : "ti-minus"
  end

  # Converts the healthy percentage to CSS class
  # to control healthy/unhealthy colors
  # @param percent [Float] the healthy percentage
  # @return [String] the corresponding color (CSS class)
  def class_for_healthy(percent)
    (percent == 100) ? "text-green" : "text-red"
  end

  # Converts the uptime to CSS class
  # to control the color of the uptime history bars
  # @param uptime [Float, nil] the uptime in percent, nil if there is no data
  # @return [String] the corresponding color (CSS class)
  def class_for_uptime(uptime)
    if uptime.nil?
      "secondary-lt"
    elsif uptime == 100
      "success"
    elsif uptime >= 99
      "warning"
    else
      "danger"
    end
  end

  # Formats the uptime for display
  # @param uptime [Float, nil] the uptime in percent, nil if there is no data
  # @return [String] eg. `99.5%` or `n/a`
  def format_uptime(uptime)
    uptime.nil? ? "n/a" : number_to_percentage(uptime, precision: 2, strip_insignificant_zeros: true)
  end
end
