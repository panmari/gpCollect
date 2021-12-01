source 'https://rubygems.org'
ruby '3.0.3'

gem 'dotenv-rails'

gem 'composite_primary_keys'
gem 'rails'
gem 'rails-i18n'
# Faster start times
gem 'bootsnap', require: false
# Sprockets v4 breaks some assumptions currently.
gem 'sprockets', '~>3.0'
gem 'bcrypt', '3.1.12' # 3.1.13 is broken on ARM, see https://github.com/rapid7/metasploit-framework/issues/11959
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', '~>0.4.0', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# For cool tables that are updated via ajax
gem 'ajax-datatables-rails'
gem 'jquery-ui-rails'
# Handling cookies easily in javascript
gem 'js_cookie_rails'
# For counting number of associated values eagerly.
gem 'activerecord-precounter'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# For easier initialization
gem 'jquery-turbolinks'
# Slick progressbar for turbolinks
gem 'nprogress-rails'

# For charts
gem 'lazy_high_charts'

# Twitter bootstrap
gem 'bootstrap', '~> 4.4.0'
# Awesome icons
gem 'font-awesome-rails'

# For pagination
gem 'bootstrap4-kaminari-views'
gem 'kaminari'

# Decorators
gem 'draper'

# For scraping web.
gem 'mechanize'

# For easy, pretty forms
gem 'simple_form'

# For authentication/login
gem 'devise'
gem 'devise-i18n'

gem 'puma'

gem 'sitemap_generator'

gem 'recaptcha', require: 'recaptcha/rails'

# For performance evaluation:
gem 'flamegraph'
gem 'rack-mini-profiler'
gem 'ruby-progressbar'
gem 'stackprof'

group :development do
  # For easier deployment
  gem 'capistrano-conditional', git: 'https://github.com/deviantech/capistrano-conditional.git', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rails-tail-log', require: false
  gem 'capistrano-service', require: false
  gem 'rvm1-capistrano3', require: false

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'listen'
  gem 'spring'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil

  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
end
