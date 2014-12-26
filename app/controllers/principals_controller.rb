class PrincipalsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :accessible_by_error_quick_fix

  def index
    # a prototyped principal is submitted with each index query. if the
    # prototype is not present, it is built here with default values
    params[:principal] ||= {}
    params[:principal][:inactive] = "0" if params[:principal][:inactive].nil?
    @principals = @principals.where(params[:principal].to_h.delete_if {|key, val| val.blank? })

    # provide a prototype principal for the filter form
    @principal = Principal.new(permitted_params[:principal])

    index!
  end
end
