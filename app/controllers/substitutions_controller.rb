class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    params[:substitution] ||= {}
    params[:substitution][:inactive] = '0' if params[:substitution][:inactive].nil?

    @substitutions = @substitutions.where(substitution_params.to_h.delete_if { |_key, val| val.blank? })

    # provide a prototype for the filter form
    @substitution = Substitution.new(substitution_params)
    respond_with @substitutions
  end

  def new
    @substitution = Substitution.new()

    if params[:mentor_id]
      @substitution.mentor = Mentor.find(params[:mentor_id])
      @substitution.kid = @substitution.mentor.kids.first
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

  def show
    redirect_to substitutions_url
  end

protected

  def substitution_params
    params.require(:substitution).permit(
      :start_at, :end_at, :mentor_id, :kid_id, :secondary_mentor_id, :comments, :inactive
    )
  end


end
