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
class Check < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_many :status_changes, dependent: :destroy

  after_create :create_job, if: :active?
  after_update :update_routine
  after_destroy :unschedule_job, if: :active?

  validates :name, presence: true
  validates :url, presence: true
  validates :url, http_url: true
  validates :cron, presence: true
  validates :cron, cron: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :healthy, -> { where('status LIKE ? AND active = ?', '2%', true) }
  scope :unhealthy, -> { where.not('status LIKE ? AND active = ?', '2%', true) }
  scope :status_1xx, -> { where('status LIKE ? AND active = ?', '1%', true) }
  scope :status_2xx, -> { where('status LIKE ? AND active = ?', '2%', true) }
  scope :status_3xx, -> { where('status LIKE ? AND active = ?', '3%', true) }
  scope :status_4xx, -> { where('status LIKE ? AND active = ?', '4%', true) }
  scope :status_5xx, -> { where('status LIKE ? AND active = ?', '5%', true) }
  scope :status_err, -> { where('NOT (status LIKE ? OR status LIKE ? OR status LIKE ? OR status LIKE ? OR status LIKE ?) AND active = ?', '1%', '2%', '3%', '4%', '5%', true) }

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

  def create_job
    job =
      Rufus::Scheduler.singleton.cron cron, job: true do
        url = URI.parse(self.url)
        begin
          response = Net::HTTP.get_response(url)
          http_code = response.code
        rescue *NET_HTTP_ERRORS => e
          status = e.to_s.tr('"', "'")
        end
        status = http_code unless e
        last_contact_at = Time.current
        Rails.logger.info "ciao-scheduler Checked '#{url}' at '#{last_contact_at}' and got '#{status}'"
        status_before = status_after = ''
        ActiveRecord::Base.connection_pool.with_connection do
          status_before = self.status
          update_columns(status: status, last_contact_at: last_contact_at, next_contact_at: job.next_times(1).first.to_local_time)
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
              check_url: Rails.application.routes.url_helpers.check_path(self)
            )
          end
        end
      end
    if job
      Rails.logger.info "ciao-scheduler Created job '#{job.id}'"
      update_columns(job: job.id, next_contact_at: job.next_times(1).first.to_local_time)
    else
      Rails.logger.error 'ciao-scheduler Could not create job'
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

  def create_tls_job
    uri = URI.parse(url)
    return unless uri.scheme == 'https'

    Rufus::Scheduler.singleton.cron '0 12 * * *', job: true do
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      tls_expires_at = nil
      http.start do |h|
        tls_expires_at = h.peer_cert.not_after
      end
      tls_expires_in_days = (tls_expires_at - Time.now).to_i / (24 * 60 * 60)
      ActiveRecord::Base.connection_pool.with_connection do
        update_columns(tls_expires_at: tls_expires_at, tls_expires_in_days: tls_expires_in_days)
      end

      if tls_expires_in_days < 30
        NOTIFICATIONS_TLS_EXPIRES.each do |notification|
          notification.notify(
            name: name,
            url: url,
            check_url: Rails.application.routes.url_helpers.check_path(self),
            tls_expires_at: tls_expires_at,
            tls_expires_in_days: tls_expires_in_days
          )
        end
      end
    end
  end

  private

  def update_routine
    if saved_change_to_attribute?(:active)
      if active
        create_job
      else
        unschedule_job
        update_columns(next_contact_at: nil, job: nil)
      end
    elsif saved_change_to_attribute?(:cron) || saved_change_to_attribute?(:url)
      Rails.logger.info "ciao-scheduler Check '#{name}' updates to cron or URL triggered job update"
      unschedule_job
      create_job
    end
  end
end
