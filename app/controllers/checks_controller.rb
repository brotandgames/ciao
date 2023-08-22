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
          redirect_to @check, notice: "Check was successfully created."
        end
        format.json { render :show, status: :created, location: @check }
      else
        format.html { render :new }
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
          redirect_to @check, notice: "Check was successfully updated."
        end
        format.json { render :show, status: :ok, location: @check }
      else
        format.html { render :edit }
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
        redirect_to checks_url, notice: "Check was successfully destroyed."
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

  # GET /checks/jobs/recreate
  # GET /checks/jobs/recreate.json
  def jobs_recreate
    Check.active.each do |check|
      check.unschedule_job if check.job
      check.create_job
    end
    Rails.logger.info "ciao-scheduler Database conn. pool stat: #{ActiveRecord::Base.connection_pool.stat}"
    respond_to do |format|
      format.html do
        redirect_to checks_url,
          notice: "Check jobs were successfully recreated."
      end
      format.json do
        render json: "Check jobs were successfully recreated.", status: 200
      end
    end
  end

  # GET /checks/admin
  def admin
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_check
    @check = Check.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def check_params
    params.require(:check).permit(:name, :cron, :url, :active)
  end
end
