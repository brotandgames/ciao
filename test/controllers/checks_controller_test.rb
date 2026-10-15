# frozen_string_literal: true

require "test_helper"

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @check = checks(:one)
    # Prevent scheduler callbacks from firing during controller tests
    Check.any_instance.stubs(:create_job)
    Check.any_instance.stubs(:create_tls_job)
    Check.any_instance.stubs(:unschedule_job)
    Check.any_instance.stubs(:unschedule_tls_job)
  end

  # -- index -----------------------------------------------------------------

  test "should get index" do
    get checks_url
    assert_response :success
  end

  test "should get index as JSON" do
    get checks_url, as: :json
    assert_response :success
    assert_equal "application/json", response.content_type.split(";").first
  end

  # -- dashboard -------------------------------------------------------------

  test "should get dashboard" do
    get root_url
    assert_response :success
  end

  # -- admin -----------------------------------------------------------------

  test "should get admin" do
    get admin_checks_url
    assert_response :success
  end

  test "admin actions are POST forms, not links Turbo could prefetch on hover" do
    get admin_checks_url
    [check_checks_path, tls_check_checks_path, notifications_test_checks_path].each do |path|
      assert_select "form[method=post][action='#{path}'] button"
      assert_select "a[href='#{path}']", count: 0
    end
  end

  # -- new -------------------------------------------------------------------

  test "should get new" do
    get new_check_url
    assert_response :success
  end

  # -- create ----------------------------------------------------------------

  test "should create check" do
    assert_difference("Check.count") do
      post checks_url, params: {
        check: {cron: @check.cron, url: @check.url, name: @check.name}
      }
    end
    assert_redirected_to check_url(Check.last)
  end

  test "should create check as JSON" do
    assert_difference("Check.count") do
      post checks_url, params: {
        check: {cron: @check.cron, url: @check.url, name: @check.name}
      }, as: :json
    end
    assert_response :created
  end

  test "should not create check with invalid params" do
    assert_no_difference("Check.count") do
      post checks_url, params: {check: {name: "", url: "not-a-url", cron: "bad"}}
    end
    assert_response :unprocessable_entity
  end

  test "should not create check with invalid params as JSON" do
    assert_no_difference("Check.count") do
      post checks_url, params: {
        check: {name: "", url: "not-a-url", cron: "bad"}
      }, as: :json
    end
    assert_response :unprocessable_entity
  end

  # -- show ------------------------------------------------------------------

  test "should show check" do
    get check_url(@check)
    assert_response :success
  end

  test "should show check as JSON" do
    get check_url(@check), as: :json
    assert_response :success
    json = response.parsed_body
    assert_equal @check.name, json["name"]
    assert_equal @check.url, json["url"]
    assert_equal %w[24h 7d 30d], json["uptime"].keys
  end

  # -- edit ------------------------------------------------------------------

  test "should get edit" do
    get edit_check_url(@check)
    assert_response :success
  end

  # -- update ----------------------------------------------------------------

  test "should update check" do
    patch check_url(@check), params: {
      check: {cron: @check.cron, url: @check.url, name: @check.name}
    }
    assert_redirected_to check_url(@check)
  end

  test "should update check as JSON" do
    patch check_url(@check), params: {
      check: {cron: @check.cron, url: @check.url, name: "Updated Name"}
    }, as: :json
    assert_response :ok
    assert_equal "Updated Name", @check.reload.name
  end

  test "should not update check with invalid params" do
    patch check_url(@check), params: {
      check: {name: "", url: "not-a-url", cron: "bad"}
    }
    assert_response :unprocessable_entity
  end

  test "should not update check with invalid params as JSON" do
    patch check_url(@check), params: {
      check: {name: "", url: "not-a-url", cron: "bad"}
    }, as: :json
    assert_response :unprocessable_entity
  end

  # -- destroy ---------------------------------------------------------------

  test "should destroy check" do
    assert_difference("Check.count", -1) do
      delete check_url(@check)
    end
    assert_redirected_to checks_url
  end

  test "should destroy check as JSON" do
    assert_difference("Check.count", -1) do
      delete check_url(@check), as: :json
    end
    assert_response :no_content
  end

  # -- job -------------------------------------------------------------------

  test "should get job when scheduler job exists" do
    job = stub_everything
    job.stubs(:next_times).returns([])
    job.stubs(:threads).returns([])
    Rufus::Scheduler.singleton.stubs(:job).returns(job)
    get check_job_url(check_id: @check.id)
    assert_response :success
  end

  test "should return 404 when scheduler job not found" do
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    get check_job_url(check_id: @check.id)
    assert_response :not_found
  end

  test "should get job as JSON when job exists" do
    Rufus::Scheduler.singleton.stubs(:job).returns(stub_everything)
    get check_job_url(check_id: @check.id), as: :json
    assert_response :ok
  end

  test "should return 404 for job as JSON when job not found" do
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    get check_job_url(check_id: @check.id), as: :json
    assert_response :not_found
  end

  # -- check_all -------------------------------------------------------------

  test "should perform checks and redirect to admin" do
    Check.any_instance.stubs(:perform_check)
    post check_checks_url
    assert_redirected_to admin_checks_url
    assert_match "Checks", flash[:notice]
  end

  test "should perform checks as JSON" do
    Check.any_instance.stubs(:perform_check)
    post check_checks_url, as: :json
    assert_response :ok
  end

  # -- notifications_test ----------------------------------------------------

  test "should send test notifications and redirect to admin" do
    notification = mock
    notification.expects(:notify!).with(has_entries(status_before: "200", status_after: "500")).once
    tls_notification = mock
    tls_notification.expects(:notify!).with(has_entries(tls_expires_in_days: 7)).once
    stub_const(:NOTIFICATIONS, [notification])
    stub_const(:NOTIFICATIONS_TLS_EXPIRES, [tls_notification])
    post notifications_test_checks_url
    assert_redirected_to admin_checks_url
    assert_match "2 test notifications", flash[:notice]
  end

  test "should report failing test notifications" do
    notification = mock
    notification.stubs(:notify!).raises(Net::SMTPAuthenticationError, "535 auth failed")
    stub_const(:NOTIFICATIONS, [notification])
    stub_const(:NOTIFICATIONS_TLS_EXPIRES, [])
    post notifications_test_checks_url
    assert_redirected_to admin_checks_url
    assert_match "535 auth failed", flash[:alert]
  end

  test "should report when no notifications are configured" do
    stub_const(:NOTIFICATIONS, [])
    stub_const(:NOTIFICATIONS_TLS_EXPIRES, [])
    post notifications_test_checks_url, as: :json
    assert_response :ok
    assert_match "No notifications", response.body
  end

  # -- tls_check_all ---------------------------------------------------------

  test "should perform tls checks and redirect to admin" do
    Check.any_instance.stubs(:perform_tls_check)
    post tls_check_checks_url
    assert_redirected_to admin_checks_url
    assert_match "TLS", flash[:notice]
  end

  test "should perform tls checks as JSON" do
    Check.any_instance.stubs(:perform_tls_check)
    post tls_check_checks_url, as: :json
    assert_response :ok
  end

  private

  # Swap a global constant (e.g. NOTIFICATIONS) for the duration of a test
  def stub_const(name, value)
    @original_consts ||= {}
    @original_consts[name] = Object.const_get(name) unless @original_consts.key?(name)
    Object.send(:remove_const, name)
    Object.const_set(name, value)
  end

  teardown do
    @original_consts&.each do |name, value|
      Object.send(:remove_const, name)
      Object.const_set(name, value)
    end
  end
end
