class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  before_filter :logout_inactive
  before_filter :intercept_sensitive_params!
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
  end

  # some parameters should only be set by admins.
  # school_id: setting this would allow access to other school's kids
  def intercept_sensitive_params!
    return true unless %w(update create).include?(action_name)
    return true if current_user.is_a?(Admin)
    if params.inspect =~ /school_id/ ||
       params.inspect =~ /inactive/
      raise SecurityError.new("User #{current_user.id} not allowed to change sensitive data")
    end
  end

  private

  # there is an unresolved error when calling cancan's accessible by
  # for certain types of users. the problem is described in ability_spec.rb in
  # the pending spec "does retrieve teachers that can be read"
  # this means that index actions for certain types of users are broken.
  # this filter redirects these users to kids index as quick fix for the
  # problem.
  def accessible_by_error_quick_fix
    return true if current_user.is_a?(Admin)
    return true unless 'index' == action_name
    redirect_to controller: 'kids', action: 'index'
  end
end
