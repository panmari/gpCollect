# frozen_string_literal: true

class RunsController < ApplicationController
  before_action :set_run, only: [:show]

  # GET /runs
  # GET /runs.json
  def index
    @runs = Run.all.includes(:category, :runner, :run_day).order(duration: :asc).page(params[:page]).decorate
  end

  # GET /runs/1
  # GET /runs/1.json
  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_run
    @run = Run.find(params[:id]).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def run_params
    params.require(:run).permit(:start, :duration, :runner_id, :category_id)
  end
end
