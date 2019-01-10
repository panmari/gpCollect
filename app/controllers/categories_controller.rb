# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]
  before_action :set_categories

  def default_url_options
    super.merge(highlighted_run_id: params[:highlighted_run_id])
  end

  # GET /categories
  def index
    highlighted_run = Run.find_by_id(params[:highlighted_run_id])
    @hist = if runner_constraint.blank?
              RuntimeHistogram.new(highlighted_run: highlighted_run)
            else
              RuntimeHistogram.new(runner_constraint: runner_constraint,
                                   highlighted_run: highlighted_run)
            end
  end

  # GET /categories/1
  def show
    @chart = CompareCategoriesChart.new(@category)
    highlighted_run = Run.find_by_id(params[:highlighted_run_id])
    @hist = if runner_constraint.blank?
              RuntimeHistogram.new(category: @category, highlighted_run: highlighted_run)
            else
              RuntimeHistogram.new(category: @category, runner_constraint: runner_constraint, highlighted_run: highlighted_run)
            end
  end

  private

  def set_categories
    @categories = Category.modern.ordered
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.includes(ordered_run_day_category_aggregates: :run_day).find_by_name(params[:id])
  end

  ALLOWED_RUNNER_CONSTRAINT_ATTRIBUTES = { first_name: :titleize, last_name: :titleize,
                                           club_or_hometown: :titleize, nationality: :upcase }.freeze

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
