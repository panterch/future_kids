# frozen_string_literal: true

class AdminsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index

  def index
    @admins = filter_index(@admins, admin_params)
    return if performed?

    # with_attached_photo: preload the avatar of every row (users/_list)
    @admins = @admins.with_attached_photo

    respond_with @admins
  end

  private

  def admin_params
    return {} if params[:admin].blank?

    params.expect(
      admin: %i[name prename email phone password password_confirmation
                address city note inactive photo]
    )
  end
end
