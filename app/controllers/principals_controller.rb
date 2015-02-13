class PrincipalsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :accessible_by_error_quick_fix

  def index
    # a prototyped principal is submitted with each index query. if the
    # prototype is not present, it is built here with default values
    principal_params[:inactive] = "0" if principal_params[:inactive].nil?
    @principals = @principals.where(principal_params.to_h.delete_if {|key, val| val.blank? })

    # provide a prototype principal for the filter form
    @principal = Principal.new(principal_params)

    index!
  end

  private

  def principal_params
    if params[:principal].present?
      params.require(:principal).permit(
       :name, :prename, :email, :password, :password_confirmation, :phone,
       :school_id, :inactive
      )
    else
      {}
    end
  end
end
