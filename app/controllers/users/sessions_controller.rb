# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # Prevent caching of the login page to avoid stale CSRF tokens
    before_action :set_no_cache, only: [:new]

    # Throttle repeated sign-in attempts from a single IP, regardless of which
    # account is targeted (covers credential stuffing / password spraying).
    rate_limit to: 20, within: 5.minutes, only: :create, name: 'ip',
               with: :render_too_many_requests

    # Throttle repeated sign-in attempts against a single account, regardless of
    # source IP (covers distributed brute-force). Complements Devise's :lockable,
    # which only kicks in after config.maximum_attempts. Requests without an
    # email fall back to the IP so they don't all share one bucket.
    rate_limit to: 10, within: 5.minutes, only: :create, name: 'email',
               by: -> { params.dig(:user, :email).to_s.strip.downcase.presence || request.remote_ip },
               with: :render_too_many_requests

    private

    def set_no_cache
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end
  end
end
