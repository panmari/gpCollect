# frozen_string_literal: true

class CompareRunnersChart < RuntimeChart
  def initialize(runners)
    super()
    ## Fill with data
    runners.each do |runner|
      data = make_runs_data(runner, &:duration)
      series(name: runner.name, data: data)
    end
  end
end
