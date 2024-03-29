# frozen_string_literal: true

class RunDay < ActiveRecord::Base
  belongs_to :organizer
  belongs_to :route
  has_many :runs
  has_many :runners, through: :runs
  has_many :run_day_category_aggregates
  has_many :categories, through: :run_day_category_aggregates

  scope :ordered_by_date, -> { order(date: :asc) }

  def self.find_by_year!(year)
    RunDay.find_by!('extract(year from date) = ?', year)
  end

  def self.most_recent_year
    RunDay.ordered_by_date.last.year
  end

  def year
    date.year
  end
end
