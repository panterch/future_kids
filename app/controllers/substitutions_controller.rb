# frozen_string_literal: true

class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    filter = substitution_params.with_defaults(inactive: '0')

    @substitutions = @substitutions.where(filter.to_h.compact_blank!)

    # provide a prototype for the filter form
    @substitution = Substitution.new(filter)
    respond_with @substitutions
  end

  def show
    redirect_to substitutions_url
  end

  def new
    @substitution = Substitution.new(kid_id: params[:kid_id])
  end

  def create
    @substitution.mentor = @substitution.kid.mentor unless @substitution.kid.nil?
    if @substitution.save
      respond_with @substitution
    else
      render :new
    end
  end

  def inactivate
    @substitution.inactive = true
    @substitution.save!

    @kid = @substitution.kid
    @kid.secondary_mentor = nil
    @kid.save!

    redirect_to action: :index
  end

  protected

  def substitution_params
    return {} if params[:substitution].blank?

    params.expect(
      substitution: %i[start_at end_at mentor_id kid_id secondary_mentor_id comments inactive]
    )
  end
end
