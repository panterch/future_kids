# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Prevent caching of the login page to avoid stale CSRF tokens
  before_action :set_no_cache, only: [:new]

  # Handle CSRF token validation failures gracefully
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token

  private

  def set_no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def handle_invalid_token
    # Log the issue for monitoring
    Rails.logger.error "CSRF token validation failed for user login: controller=#{controller_name}, action=#{action_name}, IP=#{request.remote_ip}, User-Agent=#{request.user_agent}"

    # Clear the session and redirect back to login with a helpful message
    reset_session
    flash[:alert] = 'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.'
    redirect_to new_user_session_path
  end
end
