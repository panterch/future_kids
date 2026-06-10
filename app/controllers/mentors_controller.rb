# frozen_string_literal: true

class MentorsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  def index
    # a prototyped mentor is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    filter = mentor_params.with_defaults(inactive: '0')

    # mentors are filtered by the custom criteria below; these are virtual
    # attributes and may not appear in the generic where condition
    if filter[:filter_by_coach_id].present?
      @mentors = @mentors.joins(:admins).where(kids: { admin_id: filter[:filter_by_coach_id].to_i }).distinct
    end
    if filter[:filter_by_meeting_day].present?
      @mentors = @mentors.joins(:kids).where(kids: { meeting_day: filter[:filter_by_meeting_day].to_i }).distinct
    end
    if filter[:filter_by_school_id].present?
      @mentors = @mentors.joins(:kids).where(kids: { school_id: filter[:filter_by_school_id].to_i }).distinct
    end

    # generic query building
    @mentors = @mentors.where(
      filter.except(:filter_by_coach_id, :filter_by_meeting_day, :filter_by_school_id).to_h.compact_blank!
    )

    # provide a prototype for the filter form
    @mentor = Mentor.new(filter)

    if current_user.is_a?(Admin) && params[:format] == 'xlsx'
      render xlsx: 'index', filename: "mentors-#{Time.current.strftime('%Y-%m-%d-%H-%M')}.xlsx"
    # when only one record is present, show it immediately. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    elsif !current_user.is_a?(Admin) && @mentors.one?
      redirect_to @mentors.first
    else
      respond_with @mentors
    end
  end

  def show
    # together with the mentor, a list of journal entries is shown for the
    # given year / month
    @year =  (params[:year] || Time.zone.today.year).to_i
    @month = (params[:month] || Time.zone.today.month).to_i
    @journals = @mentor.journals.where(month: @month, year: @year)

    # decouple journals from database to allow adding the virtual record
    # below and use Enumerables sum instead of ARs sum in view
    @journals = @journals.to_a

    # per default a coaching entry is added for each month
    @journals << Journal.coaching_entry(@mentor, @month, @year)
    respond_with @mentor
  end

  private

  def mentor_params
    return {} if params[:mentor].blank?

    # schedules_attributes are submitted as an array of hashes, which expect
    # requires to be declared with the double array syntax
    params.expect(
      mentor: [:name, :prename, :email, :password, :password_confirmation, :address, :sex,
               :city, :dob, :phone, :school_id, :field_of_study, :education, :transport,
               :personnel_number, :ects, :term, :absence, :note, :todo, :substitute,
               :filter_by_school_id, :filter_by_meeting_day, :filter_by_coach_id,
               :exit, :exit_kind, :exit_at,
               :inactive, :photo, { schedules_attributes: [%i[day hour minute]] }]
    )
  end
end
