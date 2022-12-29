# frozen_string_literal: true

class MergeRunnersRequestsRunDaysValidator < ActiveModel::Validator
  def validate(record)
    # uniq! returns nil if no duplicates were found.
    unless record.runners.map(&:run_days).flatten.uniq!.nil?
      # TODO: Make more useful error message.
      record.errors.add(:runners, 'At least two runners have runs on the same day.')
    end
  end
end
