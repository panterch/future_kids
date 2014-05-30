source 'https://rubygems.org'
ruby '2.1.2'

gem 'rails'

gem 'json'
gem 'haml'

gem 'jquery-rails'

gem 'unicorn'
gem 'therubyracer', platforms: :ruby

# gems in alphabetic order
gem 'cancancan'
gem 'devise'
gem 'exception_notification_rails3', require: 'exception_notifier'
gem "simple_form", '~> 3.1.0.rc1'
gem 'paperclip'
gem 'pg'
gem 'inherited_resources'
gem 'RedCloth'
gem 'show_for', github: 'plataformatec/show_for'
gem 'whenever', require: false
gem "bootstrap-sass"
gem "font-awesome-rails"
gem 'quiet_assets'
gem 'i18n_rails_helpers'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'factory_girl'
  gem 'capistrano', '~> 2.0'
  gem 'capistrano-rbenv', '~> 1.0'

  gem "pry-rails"
  gem 'pry-byebug'

  gem 'better_errors'
  gem 'binding_of_caller'
end
