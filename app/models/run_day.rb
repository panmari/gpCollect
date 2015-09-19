class RunDay < ActiveRecord::Base
  belongs_to :organizer
  belongs_to :route
  has_many :runs
  has_many :run_day_category_aggregates
  has_many :categories, through: :run_day_category_aggregates
end
