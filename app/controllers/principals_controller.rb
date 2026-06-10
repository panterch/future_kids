# frozen_string_literal: true

class PrincipalsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    # a prototyped principal is submitted with each index query. if the
    # prototype is not present, it is built here with default values
    filter = principal_params
    # the inactive filter is only permitted for admins (see principal_params)
    filter = filter.with_defaults(inactive: '0') if current_user.is_a?(Admin)
    @principals = @principals.where(filter.to_h.compact_blank!)

    # provide a prototype principal for the filter form
    @principal = Principal.new(filter)

    respond_with @principals
  end

  private

  def principal_params
    return {} if params[:principal].blank?

    keys = %i[name prename email password password_confirmation phone]
    if current_user.is_a?(Admin)
      keys << { school_ids: [] }
      keys << :inactive
    end
    params.require(:principal).permit(keys)
  end
end
