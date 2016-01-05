class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.includes(run_day_category_aggregates: :run_day).sort_by { |c| c.age_min || c.age_max }
    @chart = CompareCategoriesChart.new(@categories, 'mean')
    @min_duration_chart = CompareCategoriesChart.new(@categories, 'min')
    @participant_chart = ParticipantsChart.new(@categories)
    gender_only_categories = aggregate_to_gender(@categories)
    puts gender_only_categories
    @participant_gender_chart = ParticipantsChart.new(gender_only_categories)
    render 'show'
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @chart = CompareCategoriesChart.new(@category, 'mean')
    @min_duration_chart = CompareCategoriesChart.new(@category, 'min')
    @participant_chart = ParticipantsChart.new(@category)
  end

  private

  def aggregate_to_gender(categories)
    males = OpenStruct.new(run_day_category_aggregates: [], name: 'M')
    females = OpenStruct.new(run_day_category_aggregates: [], name: 'W')
    gender_hash = {M: males, W: females}
    RunDay.all.each do |run_day|
      run_day_agg = {M: OpenStruct.new(runs_count: 0, run_day: run_day),
                     W: OpenStruct.new(runs_count: 0, run_day: run_day)}
      categories.each do |c|
        run_day_agg[c.sex.to_sym].runs_count += c.run_day_category_aggregates.find { |a| a.run_day == run_day }.runs_count
      end
      [:M, :W].each { |g| gender_hash[g].run_day_category_aggregates << run_day_agg[g] }
    end
    gender_hash.values
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.includes(run_day_category_aggregates: :run_day).find(params[:id])
  end
end
