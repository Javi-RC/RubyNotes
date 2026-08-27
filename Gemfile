source "https://rubygems.org"

ruby "~> 3.3"

gem "bcrypt"
gem "bootsnap", require: false
gem "carrierwave"
gem "carrierwave-mongoid"
gem "dotenv-rails", groups: %i[development test]
gem "importmap-rails"
gem "jbuilder"
gem "mongoid"
gem "puma", ">= 5.0"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "sassc-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "brakeman", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  # Rails 7.1's test runner (line_filtering.rb) calls Minitest::Test.run with a
  # 5.x signature; Minitest 6 changed it and every test run aborts.
  gem "minitest", "~> 5.25"
  gem "selenium-webdriver"
end
