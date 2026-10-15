# frozen_string_literal: true

# @attr [string] name name
# @attr [string] cron cron schedule format
# @attr [datetime] created_at when the record was created in database
# @attr [datetime] updated_at when the record was last updated in database
# @attr [string] url URL to ping for healthchecking
# @attr [string] status this is either the HTTP status code 1XX..5XX or an error e
# @attr [boolean] active is healthcheck active or not?
# @attr [string] job rufus-scheduler's last run job ID
# @attr [datetime] last_contact_at when the healthcheck was last run
# @attr [datetime] next_contact_at when the healthcheck will next run
class Check < ApplicationRecord
  has_many :status_changes, dependent: :destroy

  after_create :create_job, :create_tls_job, if: :active?
  after_update :update_routine
  after_destroy :unschedule_job, :unschedule_tls_job, if: :active?

  validates :name, presence: true
  validates :url, presence: true
  validates :url, http_url: true
  validates :cron, presence: true
  validates :cron, cron: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :healthy, -> { where("status LIKE ? AND active = ?", "2%", true) }
  scope :unhealthy, -> { where.not("status LIKE ? AND active = ?", "2%", true) }
  scope :status_1xx, -> { where("status LIKE ? AND active = ?", "1%", true) }
  scope :status_2xx, -> { where("status LIKE ? AND active = ?", "2%", true) }
  scope :status_3xx, -> { where("status LIKE ? AND active = ?", "3%", true) }
  scope :status_4xx, -> { where("status LIKE ? AND active = ?", "4%", true) }
  scope :status_5xx, -> { where("status LIKE ? AND active = ?", "5%", true) }
  scope :status_err, -> { where("NOT (status LIKE ? OR status LIKE ? OR status LIKE ? OR status LIKE ? OR status LIKE ?) AND active = ?", "1%", "2%", "3%", "4%", "5%", true) }

  def self.percentage_active
    if !active.empty?
      ((active.count * 1.0 / count * 1.0) * 100.0).round(0)
    else
      0.0
    end
  end

  def self.percentage_healthy
    if !active.empty?
      ((healthy.count * 1.0 / active.count * 1.0) * 100.0).round(0)
    else
      0.0
    end
  end

  UPTIME_PERIODS = {"24h" => 1.day, "7d" => 7.days, "30d" => 30.days}.freeze

  # Uptime (share of time with status 2xx) between from and to in percent,
  # calculated from status changes. Time before the first status change is unknown
  # and not counted
  # @return [Float, nil] uptime in percent or nil if there is no data
  def uptime(from, to = Time.current, periods: status_periods(to))
    healthy = known = 0.0
    periods.each do |starts_at, ends_at, status|
      duration = [ends_at, to].min - [starts_at, from].max
      next unless duration.positive?

      known += duration
      healthy += duration if status.to_s.start_with?("2")
    end
    (healthy / known * 100).round(2) if known.positive?
  end

  # Uptime for each of UPTIME_PERIODS, eg. {"24h" => 100.0, "7d" => 99.5, "30d" => nil}
  def uptimes(now = Time.current)
    periods = status_periods(now)
    UPTIME_PERIODS.transform_values { |period| uptime(now - period, now, periods: periods) }
  end

  # Uptime per day for the last days, oldest first, eg. [[Date, 100.0], [Date, nil], ...]
  def daily_uptimes(days = 30, now = Time.current)
    periods = status_periods(now)
    (days - 1).downto(0).map do |ago|
      date = now.to_date - ago
      [date, uptime(date.in_time_zone, [(date + 1).in_time_zone, now].min, periods: periods)]
    end
  end

  # URL of the check in the Web UI, prefixed with CIAO_BASE_URL
  # Falls back to the relative path when CIAO_BASE_URL is not set
  def check_absolute_url
    base_url = ENV.fetch("CIAO_BASE_URL", "").chomp("/")
    "#{base_url}#{Rails.application.routes.url_helpers.check_path(self)}"
  end

  def perform_check
    scheduler_job = Rufus::Scheduler.singleton.job(job)
    url = URI.parse(self.url)
    response_time = nil
    begin
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response = Net::HTTP.get_response(url)
      response_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      http_code = response.code
    rescue *NET_HTTP_ERRORS => e
      status = e.to_s.tr('"', "'")
    end
    status = http_code unless e
    last_contact_at = Time.current
    next_contact_at = scheduler_job ? scheduler_job.next_times(1).first.to_local_time : self.next_contact_at
    Rails.logger.info "ciao-scheduler Checked '#{url}' at '#{last_contact_at}' and got '#{status}'"
    status_before = status_after = ""
    ActiveRecord::Base.connection_pool.with_connection do
      status_before = self.status
      update_columns(status: status, response_time: response_time, last_contact_at: last_contact_at, next_contact_at: next_contact_at)
      status_after = self.status
    end
    if status_before != status_after
      ActiveRecord::Base.connection_pool.with_connection do
        status_changes.create(status: status)
      end
      Rails.logger.info "ciao-scheduler Check '#{name}': Status changed from '#{status_before}' to '#{status_after}'"
      NOTIFICATIONS.each do |notification|
        notification.notify(
          name: name,
          status_before: status_before,
          status_after: status_after,
          url: url,
          check_url: Rails.application.routes.url_helpers.check_path(self),
          check_absolute_url: check_absolute_url
        )
      end
    end
  end

  def create_job
    check_id = id
    job =
      Rufus::Scheduler.singleton.cron cron, job: true do
        # Load the check on every run, so the job does not use the
        # name and status from the time the job was created
        check = ActiveRecord::Base.connection_pool.with_connection { Check.find_by(id: check_id) }
        check&.perform_check
      end
    if job
      Rails.logger.info "ciao-scheduler Created job '#{job.id}'"
      update_columns(job: job.id, next_contact_at: job.next_times(1).first.to_local_time)
    else
      Rails.logger.error "ciao-scheduler Could not create job"
    end
    job
  end

  def unschedule_job
    job = Rufus::Scheduler.singleton.job(self.job)

    if job
      job.unschedule
      Rails.logger.info "ciao-scheduler Unscheduled job '#{job.id}'"
    else
      Rails.logger.info "ciao-scheduler Could not unschedule job: '#{self.job}' not found"
    end
  end

  def perform_tls_check
    uri = URI.parse(url)
    return unless uri.scheme == "https"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    tls_expires_at = nil
    begin
      http.start do |h|
        tls_expires_at = h.peer_cert.not_after
      end
    rescue *NET_HTTP_ERRORS => e
      tls_expires_error = e.to_s.tr('"', "'")
    end
    if tls_expires_error
      Rails.logger.info "ciao-scheduler Checked TLS certificate of '#{url}' and got '#{tls_expires_error}'"
    else
      Rails.logger.info "ciao-scheduler Checked TLS certificate of '#{url}' and got '#{tls_expires_at}'"
      tls_expires_in_days = (tls_expires_at - Time.now).to_i / (24 * 60 * 60)
      update_columns(tls_expires_at: tls_expires_at, tls_expires_in_days: tls_expires_in_days)

      if tls_expires_in_days < 30
        NOTIFICATIONS_TLS_EXPIRES.each do |notification|
          notification.notify(
            name: name,
            url: url,
            check_url: Rails.application.routes.url_helpers.check_path(self),
            check_absolute_url: check_absolute_url,
            tls_expires_at: tls_expires_at,
            tls_expires_in_days: tls_expires_in_days
          )
        end
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create_tls_job
    uri = URI.parse(url)
    return unless uri.scheme == "https"

    check_id = id
    tls_job =
      Rufus::Scheduler.singleton.cron "0 12 * * *", job: true do
        ActiveRecord::Base.connection_pool.with_connection do
          Check.find_by(id: check_id)&.perform_tls_check
        end
      end
    if tls_job
      Rails.logger.info "ciao-scheduler Created tls_job '#{tls_job.id}'"
      update_columns(tls_job: tls_job.id)
    else
      Rails.logger.error "ciao-scheduler Could not create tls_job"
    end
    tls_job
  end

  def unschedule_tls_job
    tls_job = Rufus::Scheduler.singleton.job(self.tls_job)

    if tls_job
      tls_job.unschedule
      Rails.logger.info "ciao-scheduler Unscheduled tls_job '#{tls_job.id}'"
    else
      Rails.logger.info "ciao-scheduler Could not unschedule tls_job: '#{self.tls_job}' not found"
    end
  end

  private

  # Status changes as [starts_at, ends_at, status], each lasting until the next one
  def status_periods(now)
    changes = status_changes.where(created_at: ..now).order(:created_at).pluck(:created_at, :status)
    changes.each_with_index.map do |(starts_at, status), i|
      [starts_at, changes.dig(i + 1, 0) || now, status]
    end
  end

  def update_routine
    if saved_change_to_attribute?(:active)
      if active
        create_job
        create_tls_job
      else
        unschedule_job
        unschedule_tls_job
        update_columns(next_contact_at: nil, job: nil, tls_job: nil)
      end
    elsif saved_change_to_attribute?(:cron) || saved_change_to_attribute?(:url)
      Rails.logger.info "ciao-scheduler Check '#{name}' updates to cron or URL triggered job and tls_job update"
      unschedule_job
      unschedule_tls_job
      create_job if active?
      create_tls_job if active?
    end
  end
end
