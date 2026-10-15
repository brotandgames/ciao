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

  # -- Callbacks -------------------------------------------------------------

  test "after_create calls create_job and create_tls_job when active" do
    Check.any_instance.expects(:create_job).once
    Check.any_instance.expects(:create_tls_job).once
    Check.create!(name: "New", url: "https://example.com", cron: "* * * * *", active: true)
  end

  test "after_create does not call create_job or create_tls_job when inactive" do
    Check.any_instance.expects(:create_job).never
    Check.any_instance.expects(:create_tls_job).never
    Check.create!(name: "New", url: "https://example.com", cron: "* * * * *", active: false)
  end

  test "after_destroy calls unschedule_job and unschedule_tls_job when active" do
    Check.any_instance.stubs(:create_job)
    Check.any_instance.stubs(:create_tls_job)
    check = Check.create!(name: "New", url: "https://example.com", cron: "* * * * *", active: true)
    check.expects(:unschedule_job).once
    check.expects(:unschedule_tls_job).once
    check.destroy
  end

  test "after_destroy does not call unschedule when inactive" do
    check = Check.create!(name: "New", url: "https://example.com", cron: "* * * * *", active: false)
    check.expects(:unschedule_job).never
    check.expects(:unschedule_tls_job).never
    check.destroy
  end

  # -- #create_job -----------------------------------------------------------

  test "#create_job schedules a cron job and stores the job id" do
    check = checks(:one)
    job = stub_everything
    job.stubs(:id).returns("job-abc")
    job.stubs(:next_times).returns([stub(to_local_time: 1.minute.from_now)])
    Rufus::Scheduler.singleton.stubs(:cron).returns(job)
    check.create_job
    assert_equal "job-abc", check.reload.job
  end

  # -- #unschedule_job -------------------------------------------------------

  test "#create_job runs the check on the current check from the database" do
    check = checks(:one) # status "200"
    # Status changed since the job was created, eg. by "Check now" in admin
    Check.where(id: check.id).update_all(status: "500")
    job = stub_everything
    job.stubs(:next_times).returns([stub(to_local_time: 1.minute.from_now)])
    Rufus::Scheduler.singleton.stubs(:cron).yields.returns(job)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    stub_request(:get, "https://brotandgames.com").to_return(status: 500)
    NOTIFICATIONS.expects(:each).never
    assert_no_difference "StatusChange.count" do
      check.create_job
    end
  end

  test "#create_job does nothing when the check was deleted" do
    check = checks(:three)
    check.status_changes.delete_all
    check.delete
    Rufus::Scheduler.singleton.stubs(:cron).yields.returns(nil)
    Check.any_instance.expects(:perform_check).never
    assert_nothing_raised { check.create_job }
  end

  test "#unschedule_job unschedules an existing job" do
    check = checks(:one)
    job = stub_everything
    Rufus::Scheduler.singleton.stubs(:job).returns(job)
    job.expects(:unschedule).once
    check.unschedule_job
  end

  test "#unschedule_job does nothing when job is not found" do
    check = checks(:one)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    assert_nothing_raised { check.unschedule_job }
  end

  # -- #uptime ---------------------------------------------------------------

  def create_status_changes(check, now)
    check.status_changes.delete_all
    check.status_changes.create!(status: "200", created_at: now - 10.hours)
    check.status_changes.create!(status: "500", created_at: now - 2.hours)
    check.status_changes.create!(status: "200", created_at: now - 1.hour)
  end

  test "#uptime returns the percentage of time with 2xx status" do
    check = checks(:one)
    now = Time.current.change(usec: 0)
    create_status_changes(check, now)
    assert_equal 90.0, check.uptime(now - 10.hours, now)
  end

  test "#uptime uses the status before the window start" do
    check = checks(:one)
    now = Time.current.change(usec: 0)
    create_status_changes(check, now)
    assert_equal 80.0, check.uptime(now - 5.hours, now)
  end

  test "#uptime does not count the time before the first status change" do
    check = checks(:one)
    now = Time.current.change(usec: 0)
    create_status_changes(check, now)
    assert_equal 90.0, check.uptime(now - 24.hours, now)
  end

  test "#uptime returns nil without status changes" do
    check = checks(:one)
    check.status_changes.delete_all
    assert_nil check.uptime(1.day.ago)
  end

  test "#uptimes returns uptime for 24h, 7d and 30d" do
    check = checks(:one)
    now = Time.current.change(usec: 0)
    create_status_changes(check, now)
    assert_equal({"24h" => 90.0, "7d" => 90.0, "30d" => 90.0}, check.uptimes(now))
  end

  test "#daily_uptimes returns one uptime per day ending today" do
    check = checks(:one)
    now = Time.current.change(usec: 0)
    create_status_changes(check, now)
    daily_uptimes = check.daily_uptimes(30, now)
    assert_equal 30, daily_uptimes.size
    assert_equal now.to_date, daily_uptimes.last.first
    assert_nil daily_uptimes.first.last
  end

  # -- #check_absolute_url ---------------------------------------------------

  test "#check_absolute_url prefixes the check path with CIAO_BASE_URL" do
    check = checks(:one)
    ENV["CIAO_BASE_URL"] = "https://ciao.example.com/"
    assert_equal "https://ciao.example.com/checks/#{check.id}", check.check_absolute_url
  ensure
    ENV.delete("CIAO_BASE_URL")
  end

  test "#check_absolute_url returns the relative path without CIAO_BASE_URL" do
    check = checks(:one)
    assert_equal "/checks/#{check.id}", check.check_absolute_url
  end

  # -- #perform_check --------------------------------------------------------

  test "#perform_check updates status without status change" do
    check = checks(:one)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    stub_request(:get, "https://brotandgames.com").to_return(status: 200)
    assert_no_difference "StatusChange.count" do
      check.perform_check
    end
    assert_equal "200", check.reload.status
    assert_not_nil check.last_contact_at
  end

  test "#perform_check records status change and notifies" do
    check = checks(:one)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    stub_request(:get, "https://brotandgames.com").to_return(status: 503)
    notification = mock
    notification.expects(:notify).once
    NOTIFICATIONS.stubs(:each).yields(notification)
    assert_difference "StatusChange.count", 1 do
      check.perform_check
    end
    assert_equal "503", check.reload.status
  end

  test "#perform_check stores error message on connection errors" do
    check = checks(:one)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    stub_request(:get, "https://brotandgames.com").to_raise(Errno::ECONNREFUSED)
    check.perform_check
    assert_match "Connection refused", check.reload.status
  end

  test "#perform_check sets next_contact_at from the scheduled job" do
    check = checks(:one)
    next_time = 1.minute.from_now.change(usec: 0)
    job = stub_everything
    job.stubs(:next_times).returns([stub(to_local_time: next_time)])
    Rufus::Scheduler.singleton.stubs(:job).returns(job)
    stub_request(:get, "https://brotandgames.com").to_return(status: 200)
    check.perform_check
    assert_equal next_time, check.reload.next_contact_at
  end

  # -- #perform_tls_check ----------------------------------------------------

  test "#perform_tls_check skips http urls" do
    check = checks(:three) # http://example.com
    check.expects(:update_columns).never
    check.perform_tls_check
  end

  test "#perform_tls_check updates tls columns for https url" do
    check = checks(:one) # https://brotandgames.com
    expires_at = Time.now + 90.days
    cert = stub(not_after: expires_at)
    http = stub_everything
    http.stubs(:start).yields(stub(peer_cert: cert))
    Net::HTTP.stubs(:new).returns(http)
    check.perform_tls_check
    check.reload
    assert_not_nil check.tls_expires_at
    assert check.tls_expires_in_days > 0
  end

  test "#perform_tls_check handles connection errors gracefully" do
    check = checks(:one)
    http = stub_everything
    http.stubs(:start).raises(Errno::ECONNREFUSED)
    Net::HTTP.stubs(:new).returns(http)
    check.expects(:update_columns).never
    assert_nothing_raised { check.perform_tls_check }
  end

  # -- #create_tls_job -------------------------------------------------------

  test "#create_tls_job skips scheduling for http urls" do
    check = checks(:three) # http://example.com
    Rufus::Scheduler.singleton.expects(:cron).never
    check.create_tls_job
  end

  test "#create_tls_job schedules a daily job for https urls and stores the tls_job id" do
    check = checks(:one) # https://brotandgames.com
    tls_job = stub_everything
    tls_job.stubs(:id).returns("tls-job-abc")
    Rufus::Scheduler.singleton.stubs(:cron).returns(tls_job)
    check.create_tls_job
    assert_equal "tls-job-abc", check.reload.tls_job
  end

  test "#create_tls_job runs the TLS check on the current check from the database" do
    check = checks(:one) # https://brotandgames.com
    Check.where(id: check.id).update_all(name: "Renamed")
    tls_job = stub_everything
    Rufus::Scheduler.singleton.stubs(:cron).yields.returns(tls_job)
    http = stub_everything
    http.stubs(:start).yields(stub(peer_cert: stub(not_after: Time.now + 10.days)))
    Net::HTTP.stubs(:new).returns(http)
    notification = mock
    notification.expects(:notify).with(has_entry(:name, "Renamed")).once
    NOTIFICATIONS_TLS_EXPIRES.stubs(:each).yields(notification)
    check.create_tls_job
  end

  # -- #unschedule_tls_job ---------------------------------------------------

  test "#unschedule_tls_job unschedules an existing tls job" do
    check = checks(:one)
    tls_job = stub_everything
    Rufus::Scheduler.singleton.stubs(:job).returns(tls_job)
    tls_job.expects(:unschedule).once
    check.unschedule_tls_job
  end

  test "#unschedule_tls_job does nothing when tls job is not found" do
    check = checks(:one)
    Rufus::Scheduler.singleton.stubs(:job).returns(nil)
    assert_nothing_raised { check.unschedule_tls_job }
  end

  # -- #update_routine -------------------------------------------------------

  test "update_routine creates jobs when check is activated" do
    check = checks(:three) # inactive
    check.expects(:create_job).once
    check.expects(:create_tls_job).once
    check.update!(active: true)
  end

  test "update_routine unschedules jobs and clears columns when check is deactivated" do
    check = checks(:one) # active
    check.expects(:unschedule_job).once
    check.expects(:unschedule_tls_job).once
    check.update!(active: false)
    assert_nil check.reload.job
    assert_nil check.reload.next_contact_at
  end

  test "update_routine reschedules when cron changes" do
    check = checks(:one)
    check.expects(:unschedule_job).once
    check.expects(:unschedule_tls_job).once
    check.expects(:create_job).once
    check.expects(:create_tls_job).once
    check.update!(cron: "*/5 * * * *")
  end

  test "update_routine reschedules when url changes" do
    check = checks(:one)
    check.expects(:unschedule_job).once
    check.expects(:unschedule_tls_job).once
    check.expects(:create_job).once
    check.expects(:create_tls_job).once
    check.update!(url: "https://updated.example.com")
  end

  test "update_routine does nothing when other attributes change" do
    check = checks(:one)
    check.expects(:create_job).never
    check.expects(:create_tls_job).never
    check.expects(:unschedule_job).never
    check.expects(:unschedule_tls_job).never
    check.update!(name: "Updated Name")
  end
end
