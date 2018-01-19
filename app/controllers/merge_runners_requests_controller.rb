class MergeRunnersRequestsController < ApplicationController
  before_action :set_merge_runner_request, only: %i[show edit update destroy accept]
  before_action :authenticate_admin!, except: %i[new create]

  # GET /merge_runner_requests
  def index
    @merge_runners_requests = MergeRunnersRequest.all.includes(:runners).decorate
  end

  # GET /merge_runner_requests/1
  def show
    @merge_runners_request = @merge_runners_request.decorate
  end

  # GET /merge_runner_requests/new
  def new
    merge_candidates = Runner.includes(:run_days).find(JSON.parse(cookies[:remembered_runners] || '{}').keys)
    @merge_runners_request = MergeRunnersRequest.new_from(merge_candidates)
    @merge_runners_request.validate
    if @merge_runners_request.errors[:runners].any?
      # Runners can not be merged, show them instead.
      flash[:error] = @merge_runners_request.errors[:runners]
      redirect_to show_remembered_runners_path
    end
  end

  # GET /merge_runner_requests/1/edit
  def edit; end

  # POST /merge_runner_requests
  def create
    @merge_runners_request = MergeRunnersRequest.new(merge_runner_request_params)

    if @merge_runners_request.save
      # Delete cookie.
      cookies[:remembered_runners] = nil
      redirect_to runners_path, notice: 'Merge runner request was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /merge_runner_requests/1
  def update
    if @merge_runners_request.update(merge_runner_request_params)
      redirect_to @merge_runners_request, notice: 'Merge runner request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /merge_runner_requests/1
  def destroy
    @merge_runners_request.destroy
    redirect_to merge_runners_requests_url, notice: 'Merge runner request was successfully destroyed.'
  end

  def accept
    new_runner = @merge_runners_request.to_new_runner
    if new_runner.save!
      @merge_runners_request.runners.each &:destroy!
      flash[:info] = 'Successfully merged runner'
      redirect_to runner_path(new_runner)
    else
      flash[:error] = 'Could not create new runner: ' + new_runner.errors
      redirect_to merge_runners_requests_path
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_merge_runner_request
    @merge_runners_request = MergeRunnersRequest.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def merge_runner_request_params
    params.require(:merge_runners_request).permit(:merged_first_name, :merged_last_name, :merged_club_or_hometown,
                                                  :merged_nationality, :merged_sex, :merged_birth_date, runner_ids: [])
  end
end
