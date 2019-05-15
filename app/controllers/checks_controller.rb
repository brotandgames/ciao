class ChecksController < ApplicationController
  before_action :set_check, only: [:show, :edit, :update, :destroy]

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
        create_job(@check) if @check.active
        format.html { redirect_to @check, notice: 'Check was successfully created.' }
        format.json { render :show, status: :created, location: @check }
      else
        format.html { render :new }
        format.json { render json: @check.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checks/1
  # PATCH/PUT /checks/1.json
  def update
    respond_to do |format|
      if @check.update(check_params)
        if @check.saved_change_to_attribute?(:active)
          if @check.active
            create_job(@check)
          else
            unschedule_job(@check.job)
            @check.update_columns(next_contact_at: nil, job: nil)
          end
        elsif @check.saved_change_to_attribute?(:cron) || @check.saved_change_to_attribute?(:url)
          Rails.logger.info "ciao-scheduler Check '#{@check.name}' updates to cron or URL triggered job update"
          unschedule_job(@check.job)
          create_job(@check)
        end
        format.html { redirect_to @check, notice: 'Check was successfully updated.' }
        format.json { render :show, status: :ok, location: @check }
      else
        format.html { render :edit }
        format.json { render json: @check.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checks/1
  # DELETE /checks/1.json
  def destroy
    @check.destroy
    respond_to do |format|
      format.html { redirect_to checks_url, notice: 'Check was successfully destroyed.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check
      @check = Check.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_params
      params.require(:check).permit(:name, :cron, :url, :active)
    end

    def create_job(check)
      job =
        Rufus::Scheduler.singleton.cron check.cron, :job => true do
          url = URI.parse(check.url)
          begin
            response = Net::HTTP.get_response(url)
            http_code = response.code
          rescue *NET_HTTP_ERRORS => e
            status = e.to_s
          end
          status = http_code unless e
          last_contact_at = Time.current
          Rails.logger.info "ciao-scheduler Checked '#{url}' at '#{last_contact_at}' and got '#{status}'"
          status_before = status_after = ""
          ActiveRecord::Base.connection_pool.with_connection do
            status_before = check.status
            check.update_columns(status: status, last_contact_at: last_contact_at, next_contact_at: job.next_times(1).first.to_local_time)
            status_after = check.status
          end
          if status_before != status_after
            CheckMailer.with(name: check.name, status_before: status_before, status_after: status_after).change_status_mail.deliver
            Rails.logger.info "ciao-scheduler Sent 'changed_status' notification mail"
          end
        end
      if job
        Rails.logger.info "ciao-scheduler Created job '#{job.id}'"
        check.update_columns(job: job.id, next_contact_at: job.next_times(1).first.to_local_time)
      else
        Rails.logger.error "ciao-scheduler Could not create job"
      end
      return job
    end

    def unschedule_job(job_id)
      job = Rufus::Scheduler.singleton.job(job_id)
      if job
        job.unschedule
        Rails.logger.info "ciao-scheduler Unscheduled job '#{job.id}'"
      else
        Rails.logger.info "ciao-scheduler Could not unschedule job: '#{job_id}' not found"
      end
    end

end
