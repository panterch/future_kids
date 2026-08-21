# frozen_string_literal: true

class Rack::Attack
  # Throttle repeated sign-in attempts from a single IP, regardless of which
  # account is targeted (covers credential stuffing / password spraying).
  throttle('sign_in/ip', limit: 20, period: 5.minutes) do |req|
    req.ip if req.path == '/user/sign_in' && req.post?
  end

  # Throttle repeated sign-in attempts against a single account, regardless of
  # source IP (covers distributed brute-force). Complements Devise's :lockable,
  # which only kicks in after config.maximum_attempts.
  throttle('sign_in/email', limit: 10, period: 5.minutes) do |req|
    if req.path == '/user/sign_in' && req.post?
      email = req.params.dig('user', 'email').to_s.strip.downcase
      email.presence
    end
  end

  # Throttle password reset requests, which can be abused to spam a victim's inbox.
  throttle('password_reset/ip', limit: 10, period: 20.minutes) do |req|
    req.ip if req.path == '/user/password' && req.post?
  end
end
