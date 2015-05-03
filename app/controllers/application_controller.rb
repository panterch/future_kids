require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :authenticate_user!
  before_action :logout_inactive
  before_action :intercept_sensitive_params!
  protect_from_forgery

  protected

  def admin?
    user_signed_in? && current_user.is_a?(Admin)
  end

  def logout_inactive
    return true if 'sessions' == controller_name
    return true unless user_signed_in?
    return true unless current_user.inactive?
    sign_out current_user
    redirect_to root_url, alert: 'Benutzer/in inaktiv'
  end

  # some parameters should only be set by admins.
  # school_id: setting this would allow access to other school's kids
  def intercept_sensitive_params!
    return true unless %w(update create).include?(action_name)
    return true if current_user.is_a?(Admin)
    if params.inspect =~ /school_id/ ||
       params.inspect =~ /inactive/
      fail SecurityError.new("User #{current_user.id} not allowed to change sensitive data")
    end
  end
end
