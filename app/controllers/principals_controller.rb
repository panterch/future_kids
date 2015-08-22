class PrincipalsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    # a prototyped principal is submitted with each index query. if the
    # prototype is not present, it is built here with default values
    params[:principal] ||= {}
    params[:principal][:inactive] = '0' if params[:principal][:inactive].nil?
    @principals = @principals.where(principal_params.to_h.delete_if { |_key, val| val.blank? })

    # provide a prototype principal for the filter form
    @principal = Principal.new(principal_params)

    respond_with @principals
  end

  private

  def principal_params
    if params[:principal].present?
      keys = [:name, :prename, :email, :password, :password_confirmation, :phone ]
      if current_user.is_a?(Admin)
        keys << { school_ids: [] }
        keys << :inactive
      end
      params.require(:principal).permit(keys)
    else
      {}
    end
  end
end
