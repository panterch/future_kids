# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/cuprite'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  browser_options = {}.tap do |opts|
    opts['no-sandbox'] = nil if ENV['CI']
  end
  Capybara::Cuprite::Driver.new(app, window_size: [1400, 800], browser_options: browser_options, js_errors: true)
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Capybara::DSL

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.use_transactional_examples = true
  config.expose_current_running_example_as :example

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  Capybara.configure do |config|
    # Ignore hidden elements, mobile version hidden elements
    config.match = :prefer_exact
    # The kid-mentor-schedules page lazy-loads React (see app/javascript/application.js),
    # so its first mount takes longer than Capybara's 2s default.
    config.default_max_wait_time = 5
  end

  # Diagnostic for :js failures -- dump any failed asset/page requests (and
  # their errors) so a CI-only failure isn't a black box.
  config.after(:each, :js) do |example|
    next unless example.exception

    browser = Capybara.current_session.driver.browser
    failed = browser.network.traffic.select { |e| e.error || (e.response && e.response.status.to_i >= 400) }
    failed.each do |exchange|
      warn "[cuprite] #{exchange.url} -> status=#{exchange.response&.status} error=#{exchange.error}"
    end
  end
end
