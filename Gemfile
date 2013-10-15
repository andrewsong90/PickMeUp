source 'https://rubygems.org'

gem 'rails', '3.2.12'

# integrating with eventbrite
gem'eventbrite-client'

gem 'rake', '10.1.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :production do
  gem 'pg'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # Require the latest version of uglifier because of Windows Script Host
  gem 'uglifier', '~> 1.0.4'
  gem 'chosen-rails'
  gem 'angularjs-rails'

  # Use this instead of uglifier because of Windows Script Host. For more, see:
  # http://stackoverflow.com/questions/7877180/ror-precompiling-assets-fail-while-rake-assetsprecompile-on-basically-empty-a
  gem 'closure-compiler'
end

group :test do
  gem 'faker'
  # cabybara gem for integration test
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'selenium-webdriver'
end

gem "cocaine", "=0.5.1"
gem 'aws-sdk'

# filepicker gem for managing images
gem 'filepicker-rails'

gem 'jquery-rails'

# temporarily disable ng-rails-csrf
gem 'ng-rails-csrf', :git => "git://github.com/xrd/ng-rails-csrf.git"

# gem for facebook authorization
gem "omniauth", "~> 1.1.1"
gem "omniauth-facebook", "1.4.0"
gem 'koala'
# this gem is for configuration(?)

# gem for time manipulation
gem "time_diff", "~> 0.3.0"

# To use geocoder gem
gem 'geocoder'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# this is the gem to open spreadsheet
gem 'roo'

# this is the gem to show multiple pages
gem 'will_paginate', '>= 3.0.pre'

# populate datebase
gem 'populator'
gem 'faker'
