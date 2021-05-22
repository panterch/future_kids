class MentorMatchingsController < ApplicationController
  load_resource :kid, only: [:new, :create]
  load_and_authorize_resource :mentor_matching
  before_action :preset_kid_and_mentor, only: [:new, :create]

  def index
    @mentor_matchings = MentorMatching.accessible_by(current_ability, :manage)
  end

  def show
  end

  def new
    authorize! :search, @mentor_matching.kid
  end

  def create
    authorize! :search, @mentor_matching.kid
    if @kid.match_available? && @mentor_matching.save
      redirect_to available_kids_path
    else
      render :new
    end
  end

  def accept
    @mentor_matching.reserved! if @mentor_matching.pending?
    redirect_to @mentor_matching
  end

  def decline
    @mentor_matching.declined! if @mentor_matching.pending?
    redirect_to @mentor_matching
  end

  private

  def preset_kid_and_mentor
    @mentor_matching.mentor = current_user if current_user.is_a?(Mentor)
    @mentor_matching.kid = @kid
  end

  def mentor_matching_params
    params.require(:mentor_matching).permit(
        :message
    )
  end
end
