class AdminsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :accessible_by_error_quick_fix

  def index
    # a prototyped admin is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:admin] ||= {}
    params[:admin][:inactive] = "0" if params[:admin][:inactive].nil?
    @admins = @admins.where(params[:admin].to_h.delete_if {|key, val| val.blank? })

    # provide a prototype admin for the filter form
    @admin = Admin.new(admin_params)

    index!
  end

  private

  def admin_params
    params.require(:admin).permit(
      :name, :prename, :email, :phone, :password, :password_confirmation, :todo,
      :inactive
    )
  end
end
