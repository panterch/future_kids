class SubstitutionsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

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
      :start_at, :end_at, :mentor_id
    )
  end

end
