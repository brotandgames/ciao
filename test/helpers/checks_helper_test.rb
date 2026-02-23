# frozen_string_literal: true

require "test_helper"

class ChecksHelperTest < ActionView::TestCase
  # -- class_for_status ------------------------------------------------------

  test "class_for_status returns secondary for 1xx" do
    assert_equal "secondary", class_for_status("100")
    assert_equal "secondary", class_for_status("199")
  end

  test "class_for_status returns success for 2xx" do
    assert_equal "success", class_for_status("200")
    assert_equal "success", class_for_status("201")
    assert_equal "success", class_for_status("299")
  end

  test "class_for_status returns info for 3xx" do
    assert_equal "info", class_for_status("301")
    assert_equal "info", class_for_status("302")
  end

  test "class_for_status returns warning for 4xx" do
    assert_equal "warning", class_for_status("404")
    assert_equal "warning", class_for_status("422")
  end

  test "class_for_status returns danger for 5xx" do
    assert_equal "danger", class_for_status("500")
    assert_equal "danger", class_for_status("503")
  end

  test "class_for_status returns danger for non-numeric error strings" do
    assert_equal "danger", class_for_status("err")
    assert_equal "danger", class_for_status("")
  end

  # -- class_for_tls_expires_in_days -----------------------------------------

  test "class_for_tls_expires_in_days returns text-danger for 7 days or fewer" do
    assert_equal "text-danger", class_for_tls_expires_in_days(7)
    assert_equal "text-danger", class_for_tls_expires_in_days(0)
    assert_equal "text-danger", class_for_tls_expires_in_days(-1)
  end

  test "class_for_tls_expires_in_days returns text-warning for 8-30 days" do
    assert_equal "text-warning", class_for_tls_expires_in_days(8)
    assert_equal "text-warning", class_for_tls_expires_in_days(30)
  end

  test "class_for_tls_expires_in_days returns text for more than 30 days" do
    assert_equal "text", class_for_tls_expires_in_days(31)
    assert_equal "text", class_for_tls_expires_in_days(365)
  end

  # -- class_for_active ------------------------------------------------------

  test "class_for_active returns text-green when active" do
    assert_equal "text-green", class_for_active(true)
  end

  test "class_for_active returns text-red when inactive" do
    assert_equal "text-red", class_for_active(false)
  end

  # -- class_for_active_checkbox ---------------------------------------------

  test "class_for_active_checkbox returns ti-check when active" do
    assert_equal "ti-check", class_for_active_checkbox(true)
  end

  test "class_for_active_checkbox returns ti-minus when inactive" do
    assert_equal "ti-minus", class_for_active_checkbox(false)
  end

  # -- class_for_healthy -----------------------------------------------------

  test "class_for_healthy returns text-green when 100 percent" do
    assert_equal "text-green", class_for_healthy(100)
  end

  test "class_for_healthy returns text-red when less than 100 percent" do
    assert_equal "text-red", class_for_healthy(99)
    assert_equal "text-red", class_for_healthy(0)
  end
end
