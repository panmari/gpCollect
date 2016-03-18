source 'https://rubygems.org'
ruby '2.3.0'

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.2.1'
gem 'rails-i18n'
gem 'composite_primary_keys'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# For cool tables that are updated via ajax
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails'
gem 'ajax-datatables-rails'
# Handling cookies easily in javascript
gem 'js_cookie_rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# For easier initialization
gem 'jquery-turbolinks'
# Slick progressbar for turbolinks
gem 'nprogress-rails'

# For charts
gem 'lazy_high_charts'

# Twitter bootstrap
gem 'bootstrap-sass'
# Helpers for bootstrap
gem 'bh', '1.3.4'
# Awesome icons
gem 'font-awesome-rails'
gem 'bootswatch-rails'

# For pagination
gem 'kaminari'
gem 'bootstrap-kaminari-views'

# Decorators
gem 'draper'

# For scraping web.
gem 'mechanize'

# For easy, pretty forms
gem 'simple_form'

# For authentication/login
gem 'devise'
gem 'devise-i18n'

gem 'thin'

gem 'sitemap_generator'

# For performance evaluation:
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'

group :development do
  # For tracking progress when seeding
  gem 'ruby-progressbar'

  # For easier deployment
  gem 'capistrano-rails', require: false
  gem 'capistrano-service', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-conditional', git: 'git@github.com:panmari/capistrano-conditional.git', branch: 'colorize_fix', require: false
  gem 'capistrano-rails-tail-log', require: false

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem "codeclimate-test-reporter", require: nil

  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
end
