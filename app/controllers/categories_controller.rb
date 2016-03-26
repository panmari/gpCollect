class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.includes(run_day_category_aggregates: :run_day).sort_by { |c| c.age_min || c.age_max }
    @chart = CompareCategoriesChart.new(@categories, ['mean'])
    @min_duration_chart = CompareCategoriesChart.new(@categories, ['min'])
    @participant_chart = ParticipantsChart.new(@categories)
    cache_id = @categories.map(&:run_day_category_aggregates).flatten.map(&:id).join(',')
    gender_only_categories = Rails.cache.fetch(cache_id) do
      aggregate_to(@categories, :sex, [:M, :W])
    end
    @participant_gender_chart = ParticipantsChart.new(gender_only_categories)
    @hist = RuntimeHistogram.new
    render 'show'
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @chart = CompareCategoriesChart.new(@category)
    @participant_chart = ParticipantsChart.new(@category)
    @hist = RuntimeHistogram.new(@category)
  end

  private

  # Creates new 'run_day_category_aggregates' by aggregating existing ones by some grouping mechanism `attribute`
  # that can take on the values defined by `values`.
  def aggregate_to(categories, attribute, values)
    values.map! &:to_sym
    values_hash = values.each_with_object({}) {|v, h| h[v] = OpenStruct.new(run_day_category_aggregates: [], name: v) }
    RunDay.all.each do |run_day|
      run_day_agg = values.each_with_object({}) { |v, h| h[v] = OpenStruct.new(runs_count: 0, run_day: run_day) }
      categories.each do |c|
        corresponding_run_day = c.run_day_category_aggregates.find { |a| a.run_day == run_day }
        if corresponding_run_day
          run_day_agg[c.send(attribute).to_sym].runs_count += corresponding_run_day.runs_count
        else
          Rails.logger.warn("Could not find corresponding entry for #{run_day.inspect} in #{c.run_day_category_aggregates.inspect}")
        end
      end
      values.each { |v| values_hash[v].run_day_category_aggregates << run_day_agg[v] }
    end
    values_hash.values
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.includes(run_day_category_aggregates: :run_day).find_by_name(params[:id])
  end
end
