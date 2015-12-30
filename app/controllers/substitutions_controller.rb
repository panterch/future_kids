class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
  	#@substitutions = Substitution.where('end_at >= ?', DateTime.now).all()
  	@substitutions = Substitution.active
  end

  def new
    @substitution = Substitution.new()

  	if params[:mentor_id]
  		@substitution.mentor = Mentor.find(params[:mentor_id])
      @substitution.kid = @substitution.mentor.kids.first
    end
	end

  # REST destroy might be better
  def inactivate
    @substitution.inactive = true
    @substitution.save
    redirect_to action: :index
  end

protected 

  def substitution_params
    params.require(:substitution).permit(
      :start_at, :end_at, :mentor_id, :kid_id, :secondary_mentor_id
    )
  end


end
