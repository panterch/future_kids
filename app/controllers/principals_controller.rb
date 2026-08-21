# frozen_string_literal: true

class PrincipalsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  # school assignment is only manageable by admins - a principal changing
  # their own schools would let them reach kids/teachers outside their
  # original assignment
  guards_privileged_fields :principal, %w[school_ids]

  def index
    # a prototyped principal is submitted with each index query. if the
    # prototype is not present, it is built here with default values
    filter = principal_params
    filter = filter.with_defaults(inactive: '0') if current_user.is_a?(Admin)
    @principals = @principals.where(filter.to_h.compact_blank!)

    # provide a prototype principal for the filter form
    @principal = Principal.new(filter)

    respond_with @principals
  end

  private

  # school_ids/inactive are write-protected by guards_privileged_fields above,
  # not by role-conditional permitting here
  def principal_params
    return {} if params[:principal].blank?

    params.require(:principal).permit(
      :name, :prename, :email, :password, :password_confirmation, :phone, :inactive, school_ids: []
    )
  end
end
