class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def default_url_options
    super.merge(highlighted_run_id: params[:highlighted_run_id])
  end

  # GET /categories
  def index
    @categories = Category.modern.ordered.includes(run_day_category_aggregates: :run_day)
    @participant_chart = ParticipantsChart.new(@categories)
    highlighted_run = Run.find_by_id(params[:highlighted_run_id])
    @hist = if runner_constraint.blank?
              RuntimeHistogram.new(highlighted_run: highlighted_run)
            else
              RuntimeHistogram.new(runner_constraint: runner_constraint, highlighted_run: highlighted_run)
            end
  end

  # GET /categories/1
  def show
    @chart = CompareCategoriesChart.new(@category)
    @participant_chart = ParticipantsChart.new(@category)
    highlighted_run = Run.find_by_id(params[:highlighted_run_id])
    @hist = if runner_constraint.blank?
              RuntimeHistogram.new(category: @category, highlighted_run: highlighted_run)
            else
              RuntimeHistogram.new(category: @category, runner_constraint: runner_constraint, highlighted_run: highlighted_run)
            end
  end

  private

  # Creates new 'run_day_category_aggregates' by aggregating existing ones by some grouping mechanism `attribute`
  # that can take on the values defined by `values`.
  def aggregate_to(categories, attribute, values)
    values.map! &:to_sym
    values_hash = values.each_with_object({}) { |v, h| h[v] = OpenStruct.new(run_day_category_aggregates: [], name: v) }
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

  ALLOWED_RUNNER_CONSTRAINT_ATTRIBUTES = {first_name: :titleize, last_name: :titleize,
                                          club_or_hometown: :titleize, nationality: :upcase}

  def runner_constraint
    if admin_signed_in?
      ALLOWED_RUNNER_CONSTRAINT_ATTRIBUTES.each_with_object({}) do |attr_and_pp, constraint_hash|
        attr, post_process = *attr_and_pp
        constraint_hash[attr] = params[attr].send(post_process) unless params[attr].blank?
      end
    else
      {}
    end
  end
end
