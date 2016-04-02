require_relative 'seed_helpers'
require_relative 'merge_runners_helpers'

ActiveRecord::Base.logger = Logger.new File.open('log/development.log', 'a')

[Run, RunDay, Runner, Category, Route, Organizer].each do |model|
  model.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
end

files = SeedHelpers::input_files_hash

files.each { |file| SeedHelpers::seed_runs_file file }

MergeRunnersHelpers::merge_duplicates
Rake::Task['db:create_run_aggregates'].invoke