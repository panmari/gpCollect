class RunnersController < ApplicationController
  before_action :set_runner, only: [:show]

  # GET /runners
  # GET /runners.json
  def index
    @search_term = params[:search]
    respond_to do |format|
      format.html
      format.json { render json: RunnerDatatable.new(params) }
    end
  end

  # GET /runners/1
  # GET /runners/1.json
  def show
    @chart = ShowRunnerChart.new(@runner)
  end

  def show_remembered
    runner_ids = (params[:ids] || '').split(',')
    @runners = RunnersDecorator.decorate(Runner.includes(:runs, :run_days).find(runner_ids))
    @chart = CompareRunnersChart.new(@runners)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_runner
    @runner = Runner.includes(runs: %i[category run_day run_day_category_aggregate]).find(params[:id]).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def runner_params
    params.require(:runner).permit(:first_name, :last_name, :birth_date, :sex)
  end
end
