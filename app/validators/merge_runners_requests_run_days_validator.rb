class MergeRunnersRequestsRunDaysValidator < ActiveModel::Validator
  def validate(record)
    unless record.runners.all? { |fixed_runner| (record.runners - [fixed_runner]).all? { |other_runner| (fixed_runner.run_days & other_runner.run_days).empty? } }
      # TODO: Make more useful error message.
      record.errors[:runners] << 'At least two runners have runs on the same day.'
    end
  end
end
