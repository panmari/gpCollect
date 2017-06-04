class ShowRunnerChart < RuntimeChart
  def initialize(runner)
    super('area')
    self.chart(type: 'area')

    data = make_runs_data(runner) do |run|
      run.duration
    end
    self.series(name: I18n.t('show_runner_chart.goal'), data: data, color: '#5596DE')

    data = make_runs_data(runner) do |run|
      run.interim_times[3]
    end
    unless data.map(&:second).compact.empty?
      self.series(name: I18n.t('show_runner_chart.at_12_5_km'), data: data, color: '#3884D9')
    end

    data = make_runs_data(runner) do |run|
      run.interim_times[2]
    end
    unless data.map(&:second).compact.empty?
      self.series(name: I18n.t('show_runner_chart.at_10_km'), data: data, color: '#0968D2')
    end

    data = make_runs_data(runner) do |run|
      run.interim_times[1]
    end
    unless data.map(&:second).compact.empty?
      self.series(name: I18n.t('show_runner_chart.at_5_km'), data: data, color: '#074F9F')
    end

    data = make_runs_data(runner) do |run|
      run.interim_times[0]
    end
    unless data.map(&:second).compact.empty?
      self.series(name: I18n.t('show_runner_chart.at_2_2_km'), data: data, color: '#043872')
    end

    data = make_runs_data(runner) do |run|
      run.run_day_category_aggregate.mean_duration
    end
    self.series(name: I18n.t('show_runner_chart.mean_category'), data: data, type: 'line', color: '#222222')
  end
end
