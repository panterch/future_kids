require 'rubygems'
require 'spork'

ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do

  # https://github.com/timcharper/spork/wiki/Spork.trap_method-Jujutsu
  require "rails/application"
  Spork.trap_method(Rails::Application, :reload_routes!)

  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'views/inherited_resource_helpers'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end

Spork.each_run do
  FutureKids::Application.reload_routes!
end

Spork.each_run do
  FactoryGirl.factories.clear
  load 'spec/factories.rb'
end


RSpec.configure do |config|

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.use_transactional_examples = true

end
