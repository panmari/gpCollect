source 'https://rubygems.org'
ruby '2.4.0'

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>5.1.0'
gem 'rails-i18n'
gem 'composite_primary_keys', git: 'https://github.com/composite-primary-keys/composite_primary_keys' #'~>10.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# For cool tables that are updated via ajax
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails'
gem 'ajax-datatables-rails', '~>0.3.0'
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

gem "recaptcha", require: "recaptcha/rails"

# For performance evaluation:
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'
gem 'ruby-progressbar'

group :development do
  # For tracking progress when seeding

  # For easier deployment
  gem 'capistrano-rails', require: false
  gem 'capistrano-service', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-conditional', git: 'https://github.com/deviantech/capistrano-conditional.git', require: false
  gem 'capistrano-rails-tail-log', require: false

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'listen'
end

group :test do
  gem "codeclimate-test-reporter", require: nil

  gem 'rails-controller-testing'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
end
