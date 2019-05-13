module ChecksHelper
  def class_for_status(status)
    status == "200" ? "text-green" : "text-red"
  end
  def class_for_active(active)
    active ? "text-green" : "text-red"
  end
  def class_for_active_checkbox(active)
    active ? "fe-check" : "fe-minus"
  end
  def class_for_healthy(percent)
    percent == 100.0 ? "text-green" : "text-red"
  end
end
