class ShowRunnerChart < RuntimeChart
  def initialize(runner)
    super('area')
    self.chart(type: 'area')

    data = make_runs_data(runner) do |run|
      run.duration
    end
    self.series(name: 'Goal', data: data)

    data = make_runs_data(runner) do |run|
      run.interim_times[1]
    end
    self.series(name: 'At 10 km', data: data)

    data = make_runs_data(runner) do |run|
      run.interim_times[0]
    end
    self.series(name: 'At 5 km', data: data)

    data = make_runs_data(runner) do |run|
      run.run_day_category_aggregate.mean_duration
    end
    self.series(name: 'Mean category', data: data, type: 'line')
  end
end