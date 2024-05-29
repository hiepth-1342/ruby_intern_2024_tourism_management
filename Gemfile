source "https://rubygems.org"
git_source(:github){|repo| "https://github.com/#{repo}.git"}

ruby "3.2.2"

gem "rails", "~> 7.0.5"

gem "sprockets-rails"

gem "mysql2", "~> 0.5"

gem "puma", "~> 5.0"

gem "importmap-rails"

gem "turbo-rails"

gem "stimulus-rails"

gem "jbuilder"

gem "sassc-rails"

gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)

gem "bootsnap", require: false

gem "bcrypt", "3.1.18"

gem "config"

gem "faker", "2.21.0"

gem "pagy"

gem "dotenv-rails"

gem "i18n-js"

gem "active_storage_validations"

gem "image_processing"

gem "bootstrap"

gem "ancestry"

gem "figaro"

gem "carrierwave"

gem "mini_magick"

group :development, :test do
  gem "debug", platforms: %i(mri mingw x64_mingw)
  gem "pry-rails"
  gem "rubocop", "~> 1.26", require: false
  gem "rubocop-checkstyle_formatter", require: false
  gem "rubocop-rails", "~> 2.14.0", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
