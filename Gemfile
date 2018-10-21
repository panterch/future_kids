source 'https://rubygems.org'

gem 'rails'
gem 'haml-rails'
gem 'jquery-rails'
gem 'jbuilder'

gem 'actionview-encoded_mail_to'
gem 'axlsx_rails'
gem 'cancancan'
gem 'devise'
gem 'exception_notification'
gem 'simple_form'
gem 'paperclip'
gem 'pg'
gem 'puma'
gem 'responders'
gem 'show_for'
gem 'whenever', require: false
gem 'bootstrap-sass'
gem 'i18n_rails_helpers'
gem 'react-rails'
gem 'sassc-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'i18n-active_record'
gem 'panter-rails-deploy', '=1.3.4' # pinned because of rubyracer dependency on servers
gem 'countries'
gem 'country_select'

# pin axls to pre-version to force update of rubyzip
# can be removed as soon version is released
gem 'axlsx', :git => 'https://github.com/mdavidn/axlsx.git', :ref => 'a0b950ab2e27b1352653078c2c09a0bf94589422'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'factory_bot'
  gem 'selenium-webdriver'
  # make sure to update chromedriver on your local system and on travis
  # - chromedriver-update
  # - .travis.yml
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end
