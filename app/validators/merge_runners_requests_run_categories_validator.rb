# frozen_string_literal: true

class MergeRunnersRequestsRunCategoriesValidator < ActiveModel::Validator

  def self.compare_categories(a, b)
    [a.age_min || 0, a.age_max || 0, a.sex] <=> [b.age_min || 0, b.age_max || 0, b.sex]
  end

  def validate(record)
    ascending = record.runners.map(&:runs).flatten.sort_by { |r| r.run_day.date }.each_cons(2).all? do |previous_run, run|
      self.class.compare_categories(previous_run.category, run.category) <= 0
    end
    return if ascending

    record.errors[:runners] << 'Runs associated with these runners do not have ascending categories.'
  end
end
