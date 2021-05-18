class MentorMatchingsController < ApplicationController
  load_resource :kid
  load_and_authorize_resource :mentor_matching, through: :kid
  before_action :assign_mentor, only: [:new, :create]

  def index
    # accessible by teachers and admins only
  end

  def show
    # accessible by teachers and admins
  end

  def new
    authorize! :search, @kid
  end

  def create
    authorize! :search, @kid
    if @kid.match_available? && @mentor_matching.save      
      redirect_to available_kids_path
    else
      render :new
    end    
  end

  private

  def assign_mentor
    @mentor_matching.mentor = current_user if current_user.is_a?(Mentor)
  end

  def mentor_matching_params
    params.require(:mentor_matching).permit(
        :message
    )
  end
end
