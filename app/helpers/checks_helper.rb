# frozen_string_literal: true

module ChecksHelper
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

  def class_for_active(active)
    active ? 'text-green' : 'text-red'
  end

  def class_for_active_checkbox(active)
    active ? 'fe-check' : 'fe-minus'
  end

  def class_for_healthy(percent)
    percent == 100.0 ? 'text-green' : 'text-red'
  end
end
