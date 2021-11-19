class MentorMatchingsController < ApplicationController
  load_resource :kid, only: [:new, :create]
  load_and_authorize_resource :mentor_matching
  before_action :preset_kid_and_mentor, only: [:new, :create]

  FILTER_PARAMS = %w(mentor_id kid_id).freeze

  def index

    @mentor_matchings = MentorMatching.accessible_by(current_ability, :manage)

    # scan for and provide prototype object used for filtering
    if params[:mentor_matching]
      filter = params[:mentor_matching].permit(:kid_id, :mentor_id, :state)
      filter = filter.delete_if{ |_key, val| val.blank? }
      @mentor_matching = MentorMatching.new(filter)
      @mentor_matching.state = nil unless filter.has_key?('state')
      @mentor_matchings = @mentor_matchings.where(filter)
    end

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
      redirect_to available_kids_path, notice: I18n.t('mentor_matchings.create.notice')
    else
      render :new
    end
  end

  def accept
    @mentor_matching.reserved! if @mentor_matching.pending?
    redirect_to mentor_matchings_url, notice: I18n.t('mentor_matchings.accept.notice')
  end

  def confirm
    @mentor_matching.confirmed
    redirect_to kid_url(@mentor_matching.kid), notice: I18n.t('mentor_matchings.confirm.notice')
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
