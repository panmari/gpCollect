# frozen_string_literal: true

class MergeRunnersRequestsRunCategoriesValidator < ActiveModel::Validator
  def self.compare_categories(a, b)
    age_a = a.age_min || a.age_max
    age_b = b.age_min || b.age_max
    # If age is equal, the category that has it as age_max is smaller.
    [age_a, a.age_max || Float::INFINITY] <=> [age_b, b.age_max || Float::INFINITY]
  end

  def validate(record)
    ascending = record.runners.map(&:runs).flatten.sort_by { |r| r.run_day.date }.each_cons(2).all? do |previous_run, run|
      self.class.compare_categories(previous_run.category, run.category) <= 0
    end
    return if ascending

    record.errors[:runners] << 'Runs associated with these runners do not have ascending categories.'
  end
end
