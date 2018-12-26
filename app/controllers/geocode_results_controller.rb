# frozen_string_literal: true

class GeocodeResultsController < ApplicationController
  before_action :set_geocode_result, only: %i[show destroy]
  before_action :authenticate_admin!

  # GET /geocode_results
  def index
    @geocode_results = GeocodeResult.left_joins(:runners).group(:id)
                                    .order(Arel.sql('COUNT(runners.id) DESC'))
                                    .page(params[:page])
    ActiveRecord::Precounter.new(@geocode_results).precount(:runners)
  end

  # GET /geocode_results/1
  def show; end

  # DELETE /geocode_results/1
  def destroy
    @geocode_result.destroy
    redirect_to geocode_results_url, notice: 'Geocode result was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_geocode_result
    @geocode_result = GeocodeResult.includes(runners: { runs: :run_day }).find(params[:id])
  end
end
