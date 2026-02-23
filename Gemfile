# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use Puma as the app server
gem "puma", "~> 6.4"
# Propshaft asset pipeline (Rails 8 default)
gem "propshaft"
# Import maps for JavaScript
gem "importmap-rails"
# Hotwire's SPA-like page accelerator
gem "turbo-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.9"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "standardrb"
end

group :development do
  gem "letter_opener"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "yard"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 3.26"
  gem "mocha"
  gem "selenium-webdriver", ">= 4.0.0.rc1"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "drb"
gem "mutex_m"
# https://stackoverflow.com/questions/78617432/strange-bundle-update-issue-disappearing-net-pop-0-1-2-dependency
gem "net-pop", github: "ruby/net-pop"
gem "prometheus-client"
gem "rufus-scheduler"
gem "simple_form"
gem "yabeda-prometheus"
gem "yabeda-rails"
