# frozen_string_literal: true

require "test_helper"

class ForgeryProtectionTest < ActionDispatch::IntegrationTest
  setup do
    @check = checks(:one)
    Check.any_instance.stubs(:create_job)
    Check.any_instance.stubs(:create_tls_job)
    Check.any_instance.stubs(:unschedule_job)
    Check.any_instance.stubs(:unschedule_tls_job)
    @original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @original_allow_forgery_protection
  end

  test "rejects form POST without token" do
    assert_no_difference("Check.count") do
      assert_raises(ActionController::InvalidAuthenticityToken) do
        post "/checks", params: {check: {cron: @check.cron, url: @check.url, name: "csrf"}}
      end
    end
  end

  test "rejects form POST to .json route without token" do
    assert_no_difference("Check.count") do
      assert_raises(ActionController::InvalidAuthenticityToken) do
        post "/checks.json", params: {check: {cron: @check.cron, url: @check.url, name: "csrf"}}
      end
    end
  end

  test "rejects form DELETE via _method to .json route without token" do
    assert_no_difference("Check.count") do
      assert_raises(ActionController::InvalidAuthenticityToken) do
        post "/checks/#{@check.id}.json", params: {_method: "delete"}
      end
    end
  end

  test "rejects form POST to admin .json route without token" do
    Check.any_instance.expects(:perform_check).never
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post "/checks/check.json"
    end
  end

  test "allows JSON API requests without token" do
    assert_difference("Check.count") do
      post "/checks.json",
        params: {check: {cron: @check.cron, url: @check.url, name: "api"}}.to_json,
        headers: {"Content-Type" => "application/json"}
    end
    assert_response :created

    assert_difference("Check.count", -1) do
      delete "/checks/#{@check.id}.json", headers: {"Content-Type" => "application/json"}
    end
    assert_response :no_content
  end
end
