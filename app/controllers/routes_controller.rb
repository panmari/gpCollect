class RoutesController < ApplicationController
  before_action :set_route, only: [:show]
  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_route
    @runner = Route.find(params[:id])
  end
end
