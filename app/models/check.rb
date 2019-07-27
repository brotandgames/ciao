# frozen_string_literal: true

class Check < ApplicationRecord
  after_create :create_job, if: :active?
  after_update :update_routine

  validates :name, presence: true
  validates :url, presence: true
  validates :url, http_url: true
  validates :cron, presence: true
  validates :cron, cron: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :healthy, -> { where(status: '200', active: true) }
  scope :unhealthy, -> { where.not(status: '200', active: true) }

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
          status = e.to_s
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
          CheckMailer.with(name: name, status_before: status_before, status_after: status_after).change_status_mail.deliver
          Rails.logger.info "ciao-scheduler Sent 'changed_status' notification mail"
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
