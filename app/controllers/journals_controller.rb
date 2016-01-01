class JournalsController < ApplicationController
  # this filter has to run before cancan resource loading
  before_action :preset_mentor, only: [:create, :update]

  load_and_authorize_resource :kid
  load_and_authorize_resource :journal, through: :kid
  include CrudActions

  # these filters have to run after the resource is initialized
  before_action :prepare_mentor_selection, except: [:index, :show], if: :admin?
  before_action :preset_held_at, only: [:new]

  def create
    if @journal.save
      respond_with @journal.kid
    else
      render :new
    end
  end

  def update
    if @journal.update(journal_params)
      respond_with @journal.kid
    else
      render :edit
    end
  end

  # when a users re-loads the url after and unsuccesul edit, the url
  # points to show. show does not exist in our applications context, but
  # we want to avoid error messages sent to those users
  def show # not supported action
    redirect_to edit_kid_journal_url(@journal.kid, @journal)
  end

  def index # not supported action
    redirect_to kid_url(@kid)
  end

  def destroy
    @journal.destroy
    respond_with @journal.kid
  end

  protected

  # before giving cancan the control over the resource loading we influence
  # the created / built resource by adding some parameters to the params
  # hash
  def preset_mentor
    # for mentors we overwrite the mentor_id paramenter to assure that they
    # do not create entries for other mentors
    params[:journal][:mentor_id] = current_user.id if current_user.is_a?(Mentor)
  end

  # for admins a dropdown to select a mentor is displayed, its data is
  # collected here
  def prepare_mentor_selection
    @mentors = [@journal.kid.mentor, @journal.kid.secondary_mentor].compact
    return unless @mentors.empty?
    redirect_to kid_url(@journal.kid), alert: 'Bitte vorher einen Mentor zuordnen.'
  end

  # the value of the held_at field can be determined by the schedule of the
  # kid
  def preset_held_at
    @journal.held_at ||= @journal.kid.calculate_meeting_time&.to_date
  end

  private

  def journal_params
    if params[:journal].present?
      params.require(:journal).permit(
        :mentor_id, :held_at, :cancelled, :start_at, :end_at, :goal, :subject,
        :method, :outcome, :note
      )
    else
      {}
    end
  end
end
