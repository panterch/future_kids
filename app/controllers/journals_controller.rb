# frozen_string_literal: true

class JournalsController < ApplicationController
  load_and_authorize_resource :kid
  load_and_authorize_resource :journal, through: :kid
  include CrudActions

  # these filters have to run after the resource is initialized
  before_action :prepare_mentor_selection, except: %i[index show], if: :admin?
  before_action :preset_start_time, only: :new

  # not supported action
  def index
    redirect_to kid_url(@kid)
  end

  # when a users re-loads the url after and unsuccesul edit, the url
  # points to show. show does not exist in our applications context, but
  # we want to avoid error messages sent to those users
  # not supported action
  def show
    redirect_to edit_kid_journal_url(@journal.kid, @journal)
  end

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

  def destroy
    @journal.destroy
    respond_with @journal.kid
  end

  protected

  def preset_start_time
    @journal.start_at = @kid.meeting_start_at if @kid.meeting_start_at.present?
  end

  # for admins a dropdown to select a mentor is displayed, its data is
  # collected here
  def prepare_mentor_selection
    @mentors = [@journal.kid.mentor, @journal.kid.secondary_mentor].compact
    return unless @mentors.empty?

    redirect_to kid_url(@journal.kid), alert: t('flash.assign_mentor_first')
  end

  private

  def journal_params
    return {} if params[:journal].blank?

    permitted = params.expect(
      journal: %i[mentor_id held_at meeting_type cancelled important start_at end_at goal subject
                  method outcome note]
    )
    # for mentors we overwrite the mentor_id parameter to assure that they
    # do not create entries for other mentors
    permitted[:mentor_id] = current_user.id if current_user.is_a?(Mentor)
    permitted
  end
end
