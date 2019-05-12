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
        job = create_job(@check)
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
        if @check.saved_change_to_attribute?(:cron) || @check.saved_change_to_attribute?(:url)
          job_old = Rufus::Scheduler.singleton.job(@check.job)
          job_old.unschedule if job_old
          job = create_job(@check)
          Rails.logger.info "== #{Time.now} Check '#{@check.name}' cron '#{@check.cron}' or URL '#{@check.url}' updated"
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
  # GET /dashboard.json
  def dashboard
    @checks = Check.all
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check
      @check = Check.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_params
      params.require(:check).permit(:name, :description, :cron, :url, :active, :status)
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
          Rails.logger.info "ciao-scheduler #{Time.now} Checked '#{url}' and got '#{status}'"
          check.update_attribute(:status, status)
      end
      check.update_attribute(:job, job.id)
    end

end
