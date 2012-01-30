class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  before_filter :logout_inactive
  protect_from_forgery

protected

  def admin?
    user_signed_in? && current_user.is_a?(Admin)
  end

  def logout_inactive
    return true if 'sessions' == controller_name
    return true unless user_signed_in?
    return true unless current_user.inactive?
    redirect_to '/users/sign_out', :error => 'Benutzer inaktiv'
  end
end
