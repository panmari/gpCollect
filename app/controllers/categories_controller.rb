class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.includes(run_day_category_aggregates: :run_day).load
    @chart = CompareCategoriesChart.new(@categories, 'mean')
    @min_duration_chart = CompareCategoriesChart.new(@categories, 'min')
    @participant_chart = ParticipantsChart.new(@categories)
    render 'show'
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @chart = CompareCategoriesChart.new([@category], 'mean')
    @min_duration_chart = CompareCategoriesChart.new([@category], 'min')
    @participant_chart = ParticipantsChart.new([@category])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.includes(run_day_category_aggregates: :run_day).find(params[:id])
    end
end
