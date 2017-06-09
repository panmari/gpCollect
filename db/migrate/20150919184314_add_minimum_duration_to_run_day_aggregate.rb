class AddMinimumDurationToRunDayAggregate < ActiveRecord::Migration[4.2]
  def change
    add_column :run_day_category_aggregates, :min_duration, :integer

    reversible do |dir|
      dir.up do
        RunDayCategoryAggregate.all.each do |agg|
          agg.min_duration = agg.runs.minimum(:duration)
          agg.save!
        end
      end
    end
  end
end
