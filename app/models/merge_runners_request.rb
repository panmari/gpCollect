class MergeRunnersRequest < ActiveRecord::Base
  has_and_belongs_to_many :runners
  has_many :runs, through: :runners

  INHERITED_ATTRIBUTES = %i[first_name last_name nationality sex club_or_hometown birth_date].freeze
  VALID_SEXES = %w[M W].freeze

  validates_presence_of *INHERITED_ATTRIBUTES.map { |attr| "merged_#{attr}" }
  # TODO: Add validation for non-intersecting run days
  # TODO: Add possibly validation for edit-distance between merged and inherited attribute name.
  validates :merged_nationality, format: /\A[A-Z]{3}\z/
  validates :merged_sex, inclusion: { in: VALID_SEXES }
  validates_with MergeRunnersRequestsRunDaysValidator

  def self.new_from(merge_candidates)
    # Select most runner with most recent run as default for attributes of merge requests.
    best_mc = merge_candidates.max_by { |mc| mc.run_days.max_by(&:date) }
    # TODO: possibly do something more sophisticated with birth_date.
    merge_request_defaults = INHERITED_ATTRIBUTES.each_with_object({}) { |attr, hash| hash["merged_#{attr}"] = best_mc[attr] }
    merge_request_defaults[:runners] = merge_candidates
    new(merge_request_defaults)
  end

  # Instantiates a new runner with data from this merge request and associates all runs with the new instance. Still
  # needs to be saved in order to be written to DB!
  def to_new_runner
    runner_attributes = INHERITED_ATTRIBUTES.each_with_object({}) { |attr, hash| hash[attr] = self["merged_#{attr}"] }
    runner_attributes[:runs] = runs
    Runner.new(runner_attributes)
  end
end
