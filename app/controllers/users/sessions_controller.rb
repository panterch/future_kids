# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Prevent caching of the login page to avoid stale CSRF tokens
  before_action :set_no_cache, only: [:new]

  private

  def set_no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
