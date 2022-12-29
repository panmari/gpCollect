# frozen_string_literal: true
class MergeRunnersRequest < ActiveRecord::Base
  has_and_belongs_to_many :runners
  has_many :runs, through: :runners

  INHERITED_ATTRIBUTES = %i[first_name last_name nationality sex club_or_hometown birth_date].freeze
  VALID_SEXES = %w[M W].freeze

  validates_presence_of *INHERITED_ATTRIBUTES.map { |attr| "merged_#{attr}" }
  # TODO: Add possibly validation for edit-distance between merged and inherited attribute name.
  validates :merged_nationality, format: /\A[A-Z]{3}\z/
  validates :merged_sex, inclusion: { in: VALID_SEXES }
  validates_with MergeRunnersRequestsRunDaysValidator
  validates_with MergeRunnersRequestsRunCategoriesValidator

  def self.new_from(merge_candidates, best = nil)
    # Select most runner with most recent run as default for attributes of merge requests.
    best ||= merge_candidates.max_by { |mc| mc.run_days.max_by(&:date) }
    # TODO: possibly do something more sophisticated with birth_date.
    merge_request_attrs = INHERITED_ATTRIBUTES.each_with_object({}) { |attr, hash| hash["merged_#{attr}"] = best[attr] }
    merge_request_attrs[:runners] = merge_candidates
    new(merge_request_attrs)
  end

  # Instantiates a new runner with data from this merge request and associates all runs with the new instance. Still
  # needs to be saved in order to be written to DB!
  def to_new_runner
    runner_attributes = INHERITED_ATTRIBUTES.each_with_object({}) { |attr, hash| hash[attr] = self["merged_#{attr}"] }
    runner_attributes[:runs] = runs
    Runner.new(runner_attributes)
  end

  # Executes merge, raising an exception on issues.
  # On success, returns newly created merged runner.
  def approve!
    merged_runner = to_new_runner
    ActiveRecord::Base.transaction do
      merged_runner.save!
      runners.each(&:destroy!)
    end
    merged_runner
  end
end
