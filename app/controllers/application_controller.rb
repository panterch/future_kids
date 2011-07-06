class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  protect_from_forgery

protected

  def admin?
    user_signed_in? && current_user.is_a?(Admin)
  end
end
