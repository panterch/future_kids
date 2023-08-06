require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FutureKids
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Bern'

    config.i18n.default_locale = :de
    config.i18n.available_locales = :de
    config.i18n.fallbacks = [:de]

    # config.eager_load_paths << Rails.root.join("extras")

    # support sql views in tests
    config.active_record.schema_format = :sql

    # we dump values to webpages (e.g. in documents_controller) and
    # the escaping has to be the same as when
    config.active_support.escape_html_entities_in_json = false

    config.active_record.time_zone_aware_types = [:datetime, :time]

    # optimize country select only to available locales (this does not to work automatically with
    # i18n active_record)
    ISO3166.configure do |config|
      config.locales = [ :de ]
    end

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
