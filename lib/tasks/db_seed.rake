require 'csv'
require_relative '../../db/seed_helpers'

namespace :db do
  desc 'Try to merge runners that are most probably the same person'
  task merge_runners: :environment do
    require_relative '../../db/merge_runners_helpers'
    MergeRunnersHelpers.merge_duplicates
  end

  desc 'Seeds data from the most recent entry in SeedHeplers::input_files_hash'
  task seed_most_recent_year: :environment do
    file = SeedHelpers.input_files_hash.last
    run_day = file[:run_day]
    Run.where(run_day: run_day).destroy_all
    RunDayCategoryAggregate.where(run_day: run_day).delete_all

    SeedHelpers.seed_runs_file(file)
    Category.all.each do |category|
      RunDayCategoryAggregate.create!(category: category, run_day: run_day)
    end
  end

  desc 'Create aggregates to keep some often queried attributes cached.'
  task create_run_aggregates: :environment do
    RunDayCategoryAggregate.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(RunDayCategoryAggregate.table_name)

    Category.all.each do |category|
      RunDay.all.each do |run_day|
        # Attributes are computed with hooks.
        RunDayCategoryAggregate.create!(category: category, run_day: run_day)
      end
    end
  end

  desc 'Adds start number to existing runs'
  task add_start_numbers: :environment do
    SeedHelpers.input_files_hash.select { |h| h[:run_day].date.year >= 2007 }.each do |options|
      file = options.fetch(:file)
      shift = options.fetch(:shift, 0)
      duration_shift = options.fetch(:duration_shift, 0)
      puts "Seeding #{file} "
      run_day = options[:run_day]
      progress_bar = SeedHelpers.create_progressbar_for(file)
      updated_runners_count = 0
      ActiveRecord::Base.transaction do
        CSV.open(file, headers: true, col_sep: ';').each do |line|
          begin
            start_number = begin
                             line[3 + shift].scan(/^[0-9]+$/)[0]
                           rescue StandardError
                             next
                           end
            category_string = line[5 + shift]
            duration_string = line[10 + shift + duration_shift]
            progress_bar.increment
            next if category_string.blank? || duration_string.blank?

            duration = SeedHelpers.duration_string_to_milliseconds(duration_string)
            category = SeedHelpers.find_or_create_category_for(category_string)
            r = Run.find_by(run_day: run_day, duration: duration, category: category)
            if r
              updated_runners_count += 1
              r.update_attributes(start_number: start_number)
            end
          rescue Exception => e
            puts line
            raise e
          end
        end
      end
      progress_bar.finish
      puts "Updated #{updated_runners_count} runs"
    end
  end

  desc 'Adds alpha foto id to existing run days'
  task add_alpha_foto_id: :environment do
    { 2018 => '953',
      2017 => '869',
      2016 => '739',
      2015 => '630',
      2014 => '532',
      2013 => '430',
      2012 => '352',
      2011 => '260',
      2010 => '202' }.each do |year, alpha_foto_id|
      rd = RunDay.find_by_year!(year)
      rd.update_attributes!(alpha_foto_id: alpha_foto_id)
    end
  end
end
