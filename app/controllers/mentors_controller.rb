# frozen_string_literal: true

class MentorsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index
  include ManageSchedules # edit_schedules & update_schedules

  # personnel_number/ects/term/exit/absence/substitute are only editable by
  # admins (see app/views/mentors/_form.html.haml) but mentor_params permits
  # them regardless of role - a mentor may update their own record
  # (can :update, Mentor, id: user.id) which would otherwise let them set these
  guards_privileged_fields :mentor, %w[personnel_number ects term exit exit_kind exit_at absence substitute]

  def index
    @mentors = filter_index(@mentors, mentor_params)
    return if performed?

    # every row renders the mentor's avatar - preload photo attachment and blob
    # instead of two queries per mentor
    @mentors = @mentors.with_attached_photo

    if current_user.is_a?(Admin) && params[:format] == 'xlsx'
      # the export lists every mentor's school, kids and their schools.
      # preload, not includes: the filters join kids (e.g. by meeting day),
      # and includes would then load only the kids that match the filter
      @mentors = @mentors.preload(:school, :schools, :kids, :secondary_kids)
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
    @journals = @mentor.journals.where(month: @month, year: @year).includes(:kid)

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
               :filter_by_school_id, :filter_by_meeting_day, :filter_by_coach_id, :filter_by_availability,
               :exit, :exit_kind, :exit_at,
               :inactive, :photo, { schedules_attributes: [%i[day hour minute]] }]
    )
  end
end
