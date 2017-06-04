# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'gpCollect'
set :repo_url, 'git@github.com:panmari/gpCollect'

set :services, [:thin]
require 'capistrano/service'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/webapps/gpCollect'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
sitemap_files = ['public/sitemap.xml.gz'] + [1, 2, 3].map {|i| "public/sitemap#{i}.xml.gz"}
set :linked_files, fetch(:linked_files, []).push('.env', *sitemap_files)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('public/assets', 'log', 'db/data')
# .pus, 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

ConditionalDeploy.configure(self) do |conditional|
  conditional.register :skip_migrations, :none_match => ['db/migrate'], default: true do |c|
    c.skip_task 'deploy:migrate'
  end
end

namespace :deploy do
  # Clear existing task so we can replace it rather than "add" to it.
  #Rake::Task["deploy:compile_assets"].clear

  desc "Precompile assets locally and then rsync to web servers"
  task :compile_assets_locally do
    on roles(:app) do |host|
      execute "mkdir -p #{shared_path}/public/"
      run_locally do
        with rails_env: :production do ## Set your env accordingly.
          execute  "bundle exec rake assets:precompile"
        end
        execute "rsync -av --delete ./public/assets/ #{host.user}@#{host}:#{shared_path}/public/assets/"
        execute "rm -rf public/assets"
        # execute "rm -rf tmp/cache/assets" # in case you are not seeing changes
      end
    end
  end

  after :finished, :compile_assets_and_restart do
    on roles(:all) do
      # within release_path do
      #   execute :rake, 'tmp:clear'
      # end
      invoke 'deploy:compile_assets_locally'
      invoke 'service:thin:restart'
    end
  end
end

