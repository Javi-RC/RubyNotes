source "https://rubygems.org"

ruby "~> 3.3"

gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "sassc-rails"
gem "mongoid"
gem "bcrypt"
gem "carrierwave"
gem "carrierwave-mongoid"
gem "dotenv-rails", groups: [:development, :test]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "web-console"
  gem "brakeman", require: false
end

group :test do
  # Rails 7.1's test runner (line_filtering.rb) calls Minitest::Test.run with a
  # 5.x signature; Minitest 6 changed it and every test run aborts.
  gem "minitest", "~> 5.25"
  gem "capybara"
  gem "selenium-webdriver"
end
