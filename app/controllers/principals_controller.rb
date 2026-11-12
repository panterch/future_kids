# frozen_string_literal: true

class PrincipalsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index

  # school assignment is only manageable by admins - a principal changing
  # their own schools would let them reach kids/teachers outside their
  # original assignment
  guards_privileged_fields :principal, %w[school_ids]

  def index
    @principals = filter_index(@principals, principal_params)
    return if performed?

    # with_attached_photo: preload the avatar of every row (users/_list)
    @principals = @principals.with_attached_photo

    respond_with @principals
  end

  private

  # school_ids/inactive are write-protected by guards_privileged_fields above,
  # not by role-conditional permitting here
  def principal_params
    return {} if params[:principal].blank?

    params.expect(
      principal: [:name, :prename, :email, :password, :password_confirmation, :phone, :inactive, :photo,
                  { school_ids: [] }]
    )
  end
end
