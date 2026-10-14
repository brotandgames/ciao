# frozen_string_literal: true

class ChecksController < ApplicationController
  before_action :set_check, only: %i[show edit update destroy]

  # GET /checks
  # GET /checks.json
  def index
    @checks = Check.all
  end

  # GET /checks/1
  # GET /checks/1.json
  def show
  end

  # GET /checks/new
  def new
    @check = Check.new
  end

  # GET /checks/1/edit
  def edit
  end

  # POST /checks
  # POST /checks.json
  def create
    @check = Check.new(check_params)

    respond_to do |format|
      if @check.save
        format.html do
          redirect_to @check, notice: "Check was successfully created"
        end
        format.json { render :show, status: :created, location: @check }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @check.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /checks/1
  # PATCH/PUT /checks/1.json
  def update
    respond_to do |format|
      if @check.update(check_params)
        format.html do
          redirect_to @check, notice: "Check was successfully updated"
        end
        format.json { render :show, status: :ok, location: @check }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @check.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /checks/1
  # DELETE /checks/1.json
  def destroy
    @check.destroy
    respond_to do |format|
      format.html do
        redirect_to checks_url, notice: "Check was successfully destroyed"
      end
      format.json { head :no_content }
    end
  end

  # GET /dashboard
  def dashboard
    @checks = Check.all
  end

  # GET /checks/1/job
  # GET /checks/1/job.json
  def job
    Rails.logger.info "ciao-scheduler Database conn. pool stat: #{ActiveRecord::Base.connection_pool.stat}"
    @check = Check.find(params[:check_id])
    @job = Rufus::Scheduler.singleton.job(@check.job)
    respond_to do |format|
      if @job
        format.html
        format.json { render :job, status: :ok }
      else
        format.html { render :job, status: 404 }
        format.json { render json: "Job not found", status: 404 }
      end
    end
  end

  # POST /checks/check
  # POST /checks/check.json
  def check_all
    Check.active.each(&:perform_check)
    respond_to do |format|
      format.html do
        redirect_to admin_checks_url, status: :see_other,
          notice: "Checks were successfully performed"
      end
      format.json do
        render json: "Checks were successfully performed", status: 200
      end
    end
  end

  # POST /checks/tls/check
  # POST /checks/tls/check.json
  def tls_check_all
    Check.active.each(&:perform_tls_check)
    respond_to do |format|
      format.html do
        redirect_to admin_checks_url, status: :see_other,
          notice: "TLS checks were successfully performed"
      end
      format.json do
        render json: "TLS checks were successfully performed", status: 200
      end
    end
  end

  # POST /checks/notifications/test
  # POST /checks/notifications/test.json
  def notifications_test
    payload_data = {name: "ciao test notification", url: request.base_url, check_url: checks_path}
    count = NOTIFICATIONS.length + NOTIFICATIONS_TLS_EXPIRES.length
    errors = send_test_notifications(NOTIFICATIONS, payload_data.merge(status_before: "200", status_after: "500")) +
      send_test_notifications(NOTIFICATIONS_TLS_EXPIRES, payload_data.merge(tls_expires_at: 7.days.from_now, tls_expires_in_days: 7))
    message =
      if count.zero?
        "No notifications are configured"
      elsif errors.empty?
        "#{count} test notifications were successfully sent"
      else
        "Test notifications failed: #{errors.join(", ")}"
      end
    respond_to do |format|
      format.html do
        redirect_to admin_checks_url, status: :see_other,
          flash: {(errors.empty? ? :notice : :alert) => message}
      end
      format.json do
        render json: message, status: errors.empty? ? 200 : 500
      end
    end
  end

  # GET /checks/admin
  def admin
  end

  private

  def send_test_notifications(notifications, payload_data)
    notifications.filter_map do |notification|
      notification.notify!(payload_data)
      nil
    rescue => e
      "#{notification.class.name.demodulize}: #{e.message}"
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_check
    @check = Check.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def check_params
    params.require(:check).permit(:name, :cron, :url, :active)
  end
end
