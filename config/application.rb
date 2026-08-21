# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FutureKids
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Bern'

    # Single source of truth for session lifetime, shared by the session cookie's expire_after
    # (config/initializers/session_store.rb) and Devise's idle timeout (config/initializers/devise.rb).
    config.x.session_lifetime = 4.weeks

    config.i18n.default_locale = :de
    config.i18n.available_locales = :de
    config.i18n.fallbacks = [:de]

    # config.eager_load_paths << Rails.root.join("extras")

    # support sql views in tests
    config.active_record.schema_format = :sql

    # we dump values to webpages (e.g. in documents_controller) and
    # the escaping has to be the same as when
    config.active_support.escape_html_entities_in_json = false

    config.active_record.time_zone_aware_types = %i[datetime time]

    # encrypts sensitive attributes at rest (e.g. Site#ai_api_token). the keys must be set
    # via ENV in production; development/test fall back to fixed insecure values so the app
    # runs out of the box without extra setup
    config.active_record.encryption.primary_key =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY') { Rails.env.production? ? nil : 'insecure-dev-primary-key' }
    config.active_record.encryption.deterministic_key =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY') { Rails.env.production? ? nil : 'insecure-dev-deterministic-key' }
    config.active_record.encryption.key_derivation_salt =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT') { Rails.env.production? ? nil : 'insecure-dev-key-derivation-salt' }

    # OPTIMIZE: country select only to available locales (this does not to work automatically with
    # i18n active_record)
    ISO3166.configure do |config|
      config.locales = [:de]
    end

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
