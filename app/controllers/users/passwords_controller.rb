# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    # Throttle password reset requests, which can be abused to spam a victim's inbox.
    rate_limit to: 10, within: 20.minutes, only: :create, with: :render_too_many_requests
  end
end
