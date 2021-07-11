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
    @mentor_matching.message ||= I18n.t('mentor_matchings.new.default')
  end

  def create
    authorize! :search, @mentor_matching.kid
    if @kid.match_available?(@mentor_matching.mentor) && @mentor_matching.save
      redirect_to available_kids_path
    else
      render :new
    end
  end

  def accept
    @mentor_matching.reserved! if @mentor_matching.pending?
    redirect_to mentor_matchings_url
  end

  def confirm
    @mentor_matching.confirmed
    if can?(:read, @mentor_matching)
      redirect_to @mentor_matching
    else
      redirect_to available_kids_path
    end
  end

  def decline
    if current_user.is_a?(Teacher)
      @mentor_matching.declined(current_user) if @mentor_matching.pending?
    else
      @mentor_matching.declined(current_user)
    end
    if can?(:read, @mentor_matching)
      redirect_to mentor_matchings_url
    else
      redirect_to available_kids_path
    end
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
