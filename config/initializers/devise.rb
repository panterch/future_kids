# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = 'info@aoz-futurekids.ch'
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.remember_for = 4.weeks
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  # Idle session timeout (requires :timeoutable in User). Kept in sync with the session
  # cookie's expire_after via config.x.session_lifetime (see config/application.rb).
  config.timeout_in = Rails.application.config.x.session_lifetime
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end
