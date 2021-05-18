require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :load_site_configuration
  before_action :logout_inactive
  before_action :authenticate_user!
  before_action :intercept_sensitive_params!
  protect_from_forgery prepend: true, with: :exception

protected

  def admin?
    user_signed_in? && current_user.is_a?(Admin)
  end

  def load_site_configuration
    @site = Site.load
  end

  def logout_inactive
    return true if 'sessions' == controller_name
    return true if controller_name == 'self_registrations'
    return true unless user_signed_in?
    return true if current_user.state == 'confirmed' && !current_user.inactive?

    sign_out current_user
    redirect_to root_url, alert: 'Benutzer/in inaktiv'
  end

  # some parameters should only be set by admins.
  # school_id: setting this would allow access to other school's kids
  def intercept_sensitive_params!
    return true unless %w(update create).include?(action_name)
    return true if current_user.is_a?(Admin)
    return true if params.nil? || params.empty?
    # inactive is a sensitive param that is only manageable by admins
    if params.inspect =~ /inactive/
      fail SecurityError.new("User #{current_user.id} not allowed to change inactive flag")
    end
    # school_id may allow users for principals and teachers access to kids outside their school
    # this has to be protected (unless for kids controller, there it is
    # managed by its own method #intercept_school_id)
    # for mentors controller it is unproblematic, since it has no influence on access rights
    if %w(principals teachers).include?(controller_name) && params.inspect =~ /school_id/
      fail SecurityError.new("User #{current_user.id} not allowed to change school_id")
    end
  end

  def valid_order_by?(klass, params)
    params.split(',').map(&:strip).all? { |param| klass.column_names.include?(param) }
  end

end
