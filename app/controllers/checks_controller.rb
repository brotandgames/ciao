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
  def show; end

  # GET /checks/new
  def new
    @check = Check.new
  end

  # GET /checks/1/edit
  def edit; end

  # POST /checks
  # POST /checks.json
  def create
    @check = Check.new(check_params)

    respond_to do |format|
      if @check.save
        format.html do
          redirect_to @check, notice: 'Check was successfully created.'
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
          redirect_to @check, notice: 'Check was successfully updated.'
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
        redirect_to checks_url, notice: 'Check was successfully destroyed.'
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
        format.json { render json: 'Job not found', status: 404 }
      end
    end
  end

  # GET /checks/admin
  def admin; end

  # GET /checks/jobs/recreate
  # GET /checks/jobs/recreate.json
  def jobs_recreate
    Check.active.each do |check|
      check.unschedule_job if check.job
      check.create_job
    end
    Rails.logger.info "jobs_recreate Database conn. pool stat: #{ActiveRecord::Base.connection_pool.stat}"
    respond_to do |format|
      format.html do
        redirect_to checks_url,
                    notice: 'Check jobs were successfully recreated.'
      end
      format.json do
        render json: 'Check jobs were successfully recreated.', status: 200
      end
    end
  end

  # GET /checks/load-from-file
  # GET /checks/load-from-file.json
  def load_from_file
    errors = []
    if ENV['CIAO_CHECKS_LOAD_FROM_FILE'].present?
      Rails.logger.info "load_from_file CIAO_CHECKS_LOAD_FROM_FILE variable set to '#{ENV['CIAO_CHECKS_LOAD_FROM_FILE']}'"
      file_path = ENV.fetch('CIAO_CHECKS_LOAD_FROM_FILE', '')
      accepted_file_exts = ['.json', '.yaml', '.yml']
      file_ext = File.extname(file_path)
      if File.exist?(file_path) && accepted_file_exts.include?(file_ext)
        if ['.yaml', '.yml'].include?(file_ext)
          Rails.logger.info 'load_from_file Detected y[a]ml file'
          input_json = JSON.parse(YAML.load_file(file_path).to_json)
        else
          input_json = JSON.parse(File.read(file_path))
        end
        if input_json.respond_to?(:length) && input_json.any?
          Check.bulk_load(input_json)
        else
          Rails.logger.info "load_from_file Found no checks in #{file_path}"
          errors << 'found_no_checks'
        end
      else
        Rails.logger.info "load_from_file File #{file_path} doesn't exist or"
        Rails.logger.info "load_from_file has not accepted file extension (#{accepted_file_exts})"
        errors << 'file_not_exists_or_ext_not_accepted'
      end
    else
      Rails.logger.info 'load_from_file CIAO_CHECKS_LOAD_FROM_FILE not set'
      errors << 'CIAO_CHECKS_LOAD_FROM_FILE_not_set'
    end

    Rails.logger.info "load_from_file Database conn. pool stat: #{ActiveRecord::Base.connection_pool.stat}"
    respond_to do |format|
      if errors.any?
        format.html do
          redirect_to checks_url,
                      notice: 'Checks not loaded from file: ' + errors.join(',')
        end
        format.json do
          render json: errors, status: :unprocessable_entity
        end
      else
        notice = 'Checks were successfully loaded from file.'
        format.html do
          redirect_to checks_url,
                      notice: notice
        end
        format.json do
          render json: notice, status: 200
        end
      end
    end
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
