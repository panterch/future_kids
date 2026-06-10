# frozen_string_literal: true

class AdminsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    # a prototyped admin is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    filter = admin_params.with_defaults(inactive: '0')
    @admins = @admins.where(filter.to_h.compact_blank!)

    # provide a prototype admin for the filter form
    @admin = Admin.new(filter)

    respond_with @admins
  end

  private

  def admin_params
    return {} if params[:admin].blank?

    params.expect(
      admin: %i[name prename email phone password password_confirmation
                address city note inactive]
    )
  end
end
