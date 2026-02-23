# frozen_string_literal: true

require "test_helper"

class CheckTest < ActiveSupport::TestCase
  # -- Validations -----------------------------------------------------------

  test "is valid with valid attributes" do
    check = Check.new(name: "Test", url: "https://example.com", cron: "* * * * *")
    assert check.valid?
  end

  test "is valid with http url" do
    check = Check.new(name: "Test", url: "http://example.com", cron: "* * * * *")
    assert check.valid?
  end

  test "is invalid without name" do
    check = Check.new(url: "https://example.com", cron: "* * * * *")
    assert_not check.valid?
    assert_includes check.errors[:name], "can't be blank"
  end

  test "is invalid without url" do
    check = Check.new(name: "Test", cron: "* * * * *")
    assert_not check.valid?
    assert_includes check.errors[:url], "can't be blank"
  end

  test "is invalid with non-HTTP url" do
    check = Check.new(name: "Test", url: "ftp://example.com", cron: "* * * * *")
    assert_not check.valid?
    assert_includes check.errors[:url], "is not a valid HTTP URL"
  end

  test "is invalid with malformed url" do
    check = Check.new(name: "Test", url: "not-a-url", cron: "* * * * *")
    assert_not check.valid?
    assert check.errors[:url].any?
  end

  test "is invalid without cron" do
    check = Check.new(name: "Test", url: "https://example.com")
    assert_not check.valid?
    assert_includes check.errors[:cron], "can't be blank"
  end

  test "is invalid with invalid cron expression" do
    check = Check.new(name: "Test", url: "https://example.com", cron: "not-a-cron")
    assert_not check.valid?
    assert check.errors[:cron].any?
  end

  test "is valid with standard cron expression" do
    check = Check.new(name: "Test", url: "https://example.com", cron: "*/5 * * * *")
    assert check.valid?
  end

  # -- Scopes ----------------------------------------------------------------

  test ".active returns only active checks" do
    assert_equal 2, Check.active.count
    assert Check.active.all?(&:active?)
  end

  test ".inactive returns only inactive checks" do
    assert_equal 1, Check.inactive.count
    assert Check.inactive.none?(&:active?)
  end

  test ".healthy returns active checks with 2xx status" do
    assert_equal 1, Check.healthy.count
    assert Check.healthy.all? { |c| c.active? && c.status.start_with?("2") }
  end

  test ".unhealthy does not include checks with 2xx status and active" do
    assert Check.unhealthy.none? { |c| c.active? && c.status.to_s.start_with?("2") }
  end

  test ".status_2xx returns active checks with 2xx status" do
    assert_equal 1, Check.status_2xx.count
    assert Check.status_2xx.all? { |c| c.active? && c.status.start_with?("2") }
  end

  test ".status_5xx returns active checks with 5xx status" do
    assert_equal 1, Check.status_5xx.count
    assert Check.status_5xx.all? { |c| c.active? && c.status.start_with?("5") }
  end

  test ".status_1xx returns active checks with 1xx status" do
    assert_equal 0, Check.status_1xx.count
  end

  test ".status_3xx returns active checks with 3xx status" do
    assert_equal 0, Check.status_3xx.count
  end

  test ".status_4xx returns active checks with 4xx status" do
    assert_equal 0, Check.status_4xx.count
  end

  test ".status_err returns active checks with non-HTTP status" do
    assert_equal 0, Check.status_err.count
  end

  # -- Class methods ---------------------------------------------------------

  test ".percentage_active returns correct percentage" do
    # 2 active out of 3 total = 67%
    assert_equal 67, Check.percentage_active
  end

  test ".percentage_active returns 0.0 when no checks are active" do
    Check.update_all(active: false)
    assert_equal 0.0, Check.percentage_active
  end

  test ".percentage_healthy returns correct percentage" do
    # 1 healthy (2xx + active) out of 2 active = 50%
    assert_equal 50, Check.percentage_healthy
  end

  test ".percentage_healthy returns 0.0 when no checks are active" do
    Check.update_all(active: false)
    assert_equal 0.0, Check.percentage_healthy
  end
end
