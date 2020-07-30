# frozen_string_literal: true

set :application, 'gpCollect'
set :repo_url, 'git@github.com:panmari/gpCollect'

set :services, [:puma]
require 'capistrano/service'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/webapps/gpCollect'

# Don't add --deployment and bundle path, we need to share gems along all
# projects to save resources
# Also don't add --quiet, installing gems takes a very long time.
set :bundle_path, nil
set :bundle_flags, nil

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, '.env'
append :linked_files, 'public/sitemap.xml.gz'

# Default value for linked_dirs is []
append :linked_dirs, 'public/assets', 'log', 'db/data', '.bundle'
# .pus, 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :keep_assets, 2

ConditionalDeploy.configure(self) do |conditional|
  conditional.register :skip_migrations, none_match: ['db/migrate'], default: true do |c|
    c.skip_task 'deploy:migrate'
  end
end

namespace :deploy do
  after :finished, :compile_assets_and_restart do
    on roles(:all) do
      # within release_path do
      #   execute :rake, 'tmp:clear'
      # end
      invoke 'service:puma:restart'
    end
  end
end
