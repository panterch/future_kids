class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
  	@substitutions = Substitution.all()
  end

  def new
  	#TODO: save all substitutions
  	Mentor.find(params[:mentor_id]).kids.each do |kid|
  		@substitution = Substitution.new(:mentor_id => params[:mentor_id], :kid_id => kid.id)
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
      :start_at, :end_at, :mentor_id, :kid_id, :secondary_mentor_id
    )
  end

end
