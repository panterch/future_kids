# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'haml-rails'
gem 'importmap-rails'
gem 'propshaft'
gem 'rails'
gem 'rails-i18n'

gem 'active_storage_validations'
gem 'bootstrap'
gem 'cancancan'
gem 'countries'
gem 'country_select'
gem 'dartsass-rails'
gem 'devise'
gem 'google-cloud-storage', require: false
gem 'image_processing'
gem 'jaro_winkler'
gem 'pg'
gem 'redcarpet'
gem 'responders'
gem 'ruby-vips'
gem 'simple_form'

gem 'caxlsx'
gem 'caxlsx_rails'

gem 'puma'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'shoulda-matchers'
end

group :production do
  gem 'exception_notification'
end
