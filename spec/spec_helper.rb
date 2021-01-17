ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'webdrivers/chromedriver'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }


Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end



RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Capybara::DSL

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.use_transactional_examples = false
  config.expose_current_running_example_as :example

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures/files"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:transaction)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = if example.metadata[:js]
                                 :truncation
                               else
                                 :transaction
                               end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end


  # Clear ActionMailer deliveries after each spec.
  config.after(:each) { ActionMailer::Base.deliveries.clear }

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  # Ignore hidden elements, mobile version hidden elements
  Capybara.configure do |config|
    config.match = :prefer_exact
  end
end
