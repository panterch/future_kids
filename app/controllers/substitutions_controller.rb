class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
  	#@substitutions = Substitution.where('end_at >= ?', DateTime.now).all()
  	@substitutions = Substitution.where(closed: false).order('start_at asc').all()
  end

  def new
    @substitution = Substitution.new()

  	if params[:mentor_id]
  		@substitution.mentor = Mentor.find(params[:mentor_id])
      @substitution.kid = @substitution.mentor.kids.first
    end
	end

  # really needed?
  def create
    @substitution = Substitution.new(substitution_params)
    if @substitution.save
      redirect_to action: :index
    else
      render :new
    end
  end

  # really needed?
  def update
    if @substitution.update(substitution_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  # REST destroy ?
  # inactive ;-)
  def close
    @substitution.closed = true
    @substitution.save
    redirect_to action: :index
  end

protected 

  def substitution_params
    params.require(:substitution).permit(
      :start_at, :end_at, :mentor_id, :kid_id, :secondary_mentor_id, :closed
    )
  end


end
