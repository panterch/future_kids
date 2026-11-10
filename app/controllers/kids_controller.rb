# frozen_string_literal: true

class KidsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index
  include ManageSchedules # edit_schedules & update_schedules

  # mentor/admin assignment and exit/termination fields are only editable by
  # admins (see app/views/kids/_form.html.haml) but kid_params permits them
  # regardless of role - load_and_authorize_resource only restricts which
  # kids may be updated, not which attributes on them. teacher_id and its
  # secondary/third variants are excluded here: teachers are legitimately
  # allowed to assign themselves/other teachers on kids they create (see
  # #assign_current_teacher and the "assign itself as teacher" specs)
  guards_privileged_fields :kid, %w[
    mentor_id secondary_mentor_id secondary_active
    admin_id term exit exit_reason exit_kind exit_at checked_at coached_at
  ]

  before_action :cancan_prototypes, only: [:show]
  before_action :assign_current_teacher, only: [:create]
  before_action :intercept_school_id
  before_action :load_and_constrain_schools, except: %i[index show show_kid_mentors_schedules]
  after_action :track_creation_relation, only: [:create]

  def index
    @kids = filter_index(@kids, kid_params)
    return if performed?

    # each row shows the mentor's and the coach's avatar
    @kids = @kids.includes(mentor: { photo_attachment: :blob }, admin: { photo_attachment: :blob })

    if current_user.is_a?(Admin) && params[:format] == 'xlsx'
      # the export also lists every kid's school, teacher and secondary mentor
      @kids = @kids.includes(:school, :teacher, :secondary_mentor)
      return render xlsx: 'index', filename: "kids-#{Time.current.strftime('%Y-%m-%d-%H-%M')}.xlsx"
    end

    respond_with @kids
  end

  # update is called from the normal rails edit form and from the react
  # component on show_kid_mentors_schedules
  def update
    return render :edit unless @kid.update(kid_params)

    respond_with @kid
  end

  def show
    if params[:format] == 'md'
      raise CanCan::AccessDenied unless current_user.is_a?(Admin)

      return render formats: [:md], locals: { redactor: NameRedactor.new(@kid) } if params[:redacted].present?

      return render formats: [:md]
    end

    preload_history
    respond_with @kid
  end

  def show_kid_mentors_schedules
    @mentors = Mentor.active.includes(:kids, :secondary_kids, :schools, :schedules)
    @schools = School.all
    @kid_mentor_schedules_data = helpers.kid_mentor_schedules_data(@kid, @mentors, @schools)
    respond_to do |format|
      format.html
      format.json { render json: @kid_mentor_schedules_data }
    end
  end

  protected

  # when the user working on the kid is a teacher, it get's
  # assigned as the first teacher of the kid in creation case
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    return true if @kid.teacher.present?

    return if @kid.secondary_teacher == current_user || @kid.third_teacher == current_user

    @kid.teacher ||= current_user
  end

  def track_creation_relation
    return true unless @kid.persisted?

    @kid.relation_logs.create(user_id: current_user.id,
                              role: 'creator',
                              start_at: Time.zone.now)
  end

  # prototypes to check abilities in menu
  def cancan_prototypes
    @cancan_journal = Journal.new(kid: @kid)
    @cancan_review = Review.new(kid: @kid)
    @cancan_journal.mentor = current_user if current_user.is_a?(Mentor)
    @cancan_first_year_assessment = FirstYearAssessment.new(kid: @kid)
    @cancan_termination_assessment = TerminationAssessment.new(kid: @kid)
  end

  private

  # the kid page lists every journal (with its comments) and assessment, each
  # rendering a user's avatar - load them up front instead of per entry
  def preload_history
    photo = { photo_attachment: :blob }
    ActiveRecord::Associations::Preloader.new(
      records: [@kid],
      associations: [
        :teacher, :secondary_teacher, :third_teacher, :mentor, :secondary_mentor, :admin, :school,
        { journals: [{ mentor: photo }, { comments: { created_by: photo } }],
          first_year_assessments: [{ mentor: photo }, { teacher: photo }],
          termination_assessments: { teacher: photo } }
      ]
    ).call
  end

  def kid_params
    return {} if params[:kid].blank?

    # schedules_attributes are submitted as an array of hashes, which expect
    # requires to be declared with the double array syntax
    params.expect(
      kid: [
        :name, :prename, :sex, :dob, :grade, :language, :parent_country, :parent, :address,
        :city, :phone, :translator, :note, :school_id,
        :goal_1, :goal_2, :goal_3, :goal_4, :goal_5, :goal_6, :goal_7, :goal_8, :goal_9, :goal_10,
        :goal_11, :goal_12, :goal_13, :goal_14, :goal_15, :goal_16, :goal_17, :goal_18, :goal_19,
        :goal_20, :goal_21, :goal_22, :goal_23, :goal_24, :goal_25, :goal_26, :goal_27, :goal_28,
        :goal_29, :goal_30, :goal_31, :goal_32, :goal_33, :goal_34, :goal_35,
        :simplified_schedule,
        :meeting_day, :meeting_start_at, :teacher_id, :secondary_teacher_id,
        :third_teacher_id, :mentor_id, :secondary_mentor_id, :secondary_active, :admin_id, :term,
        :exit, :exit_reason, :exit_kind, :exit_at, :checked_at,
        :coached_at, :todo, :inactive, :filter_by_availability,
        { schedules_attributes: [%i[day hour minute]] }
      ]
    )
  end

  def load_and_constrain_schools
    case current_user
    when Teacher
      @schools = [current_user.school]
      @schools_include_blank = false
    when Principal
      @schools = current_user.schools
      @schools_include_blank = false
    when Admin
      @schools = School.by_kind(:kid)
      @schools_include_blank = true
    else
      raise SecurityError, "User #{current_user.id}"
    end
  end

  # do not let teachers and principals change the school id of foreign
  # objects not to let kids be assigned to other entities
  def intercept_school_id
    return if current_user.is_a?(Admin)

    school_id = params[:kid] && params[:kid][:school_id]
    return if school_id.blank?

    valid_school_ids = []
    if current_user.is_a?(Principal)
      valid_school_ids = current_user.schools.map(&:id)
    elsif current_user.is_a?(Teacher)
      valid_school_ids = [current_user.school_id]
    end
    return if valid_school_ids.map(&:to_s).include?(school_id)

    raise SecurityError, "User #{current_user.id} not allowed to change school_id to #{school_id}"
  end
end
