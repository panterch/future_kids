class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
  	#@substitutions = Substitution.where('end_at >= ?', DateTime.now).all()
  	@substitutions = Substitution.where(closed: false).order('start_at asc').all()
  end

  def new
  	if(params.has_key?(:mentor_id))

  		mentor = Mentor.find(params[:mentor_id])

  		kid_id = nil
  		#TODO: find all kids
	  	mentor.kids.each do |kid|
	  		kid_id = kid.id
	  	end
	  	@substitution = Substitution.new(:mentor => mentor, :kid_id => kid_id)
		
	  else
	  	@substitution = Substitution.new()
	  end
	end

  def create
    @substitution = Substitution.new(substitution_params)
    if @substitution.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    if @substitution.update(substitution_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def substitution_params
    params.require(:substitution).permit(
      :start_at, :end_at, :mentor_id, :kid_id, :secondary_mentor_id, :closed
    )
  end

  def close
  	@substitution.closed = true
  	@substitution.save
  	redirect_to action: :index
  end

end
