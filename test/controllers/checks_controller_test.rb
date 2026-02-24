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

  # -- jobs_recreate ---------------------------------------------------------

  test "should recreate jobs and redirect" do
    get jobs_recreate_checks_url
    assert_redirected_to checks_url
    assert_match "recreated", flash[:notice]
  end

  test "should recreate jobs as JSON" do
    get jobs_recreate_checks_url, as: :json
    assert_response :ok
  end

  # -- tls_check_all ---------------------------------------------------------

  test "should perform tls checks and redirect to admin" do
    Check.any_instance.stubs(:perform_tls_check)
    get tls_check_checks_url
    assert_redirected_to admin_checks_url
    assert_match "TLS", flash[:notice]
  end

  test "should perform tls checks as JSON" do
    Check.any_instance.stubs(:perform_tls_check)
    get tls_check_checks_url, as: :json
    assert_response :ok
  end
end
