# frozen_string_literal: true

require "test_helper"

class StatusChangeTest < ActiveSupport::TestCase
  test "belongs to a check" do
    status_change = status_changes(:one)
    assert_instance_of Check, status_change.check
  end

  test "is invalid without a check" do
    status_change = StatusChange.new(status: "200")
    assert_not status_change.valid?
  end

  test "is valid with a check and status" do
    status_change = StatusChange.new(status: "200", check: checks(:one))
    assert status_change.valid?
  end
end
