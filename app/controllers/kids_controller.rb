class KidsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  before_action :cancan_prototypes, only: [:show]
  before_action :assign_current_teacher, only: [:create]
  before_action :prepare_substitution
  before_action :intercept_school_id
  before_action :load_and_constrain_schools, except: [:index, :show, :show_kid_mentors_schedules]
  after_action :track_creation_relation, only: [:create]

  def index


    # for admin users, the kids view may be filtered. these code is only
    # executed for admins since else we would have to take care that no other
    # user overwrites its filter constraints by adding a certain query parameter
    # here
    if current_user.is_a?(Admin) || current_user.is_a?(Principal)
      # a prototyped kid is submitted with each index query. if the prototype
      # is not present, it is built here with default values
      # build a where condition out of all parameters supplied for kid
      params[:kid] ||= {}
      params[:kid][:inactive] = '0' if params[:kid][:inactive].nil?
      @kids = @kids.where(kid_params.to_h.delete_if { |key, val| !Kid.column_names.include?(key.to_s) || val.blank? })
      # reorder the kids according to the supplied parameter

      if params['order_by'] && valid_order_by?(Kid, params['order_by'])
        @kids = @kids.reorder(params['order_by'])
      end
      # provide a prototype for the filter form
      @kid = Kid.new(kid_params)
    end

    if current_user.is_a?(Admin) && 'xlsx' == params[:format]
      return render xlsx: 'index'
    else
      respond_with @kids
    end
  end

  # update may be called from different sources
  # - normal rails edit form
  # - react component on show_kid_mentors_schedules
  # - react component on show_kid_mentors_schedules in substitution workflow
  def update

    unless @kid.update(kid_params)
      # validation failed
      return render :edit
    end

    # normal call - not through substitution workflow
    unless @substitution
      return respond_with(@kid)
    end

    # call included substitution_id: sync substitution information
    @substitution.update!(secondary_mentor: @kid.secondary_mentor)
    redirect_to substitution_url(@substitution)
  end

  def show_kid_mentors_schedules

    # prepare substitution json
    @kid_mentor_schedules_data = Jbuilder.new do |json|
      json.mentors do
        Mentor.active.each do |mentor|
          json.set! mentor.id do
            json.id mentor.id
            json.prename mentor.prename
            json.name mentor.name
            json.sex mentor.sex
            json.ects mentor.ects
            json.kids mentor.kids, :id, :name, :prename
            json.secondary_kids mentor.secondary_kids, :id, :name, :prename
            json.schools mentor.schools.ids
            json.schedules create_schedules_nested_set mentor.schedules
          end
        end
      end
      json.kid do
        json.id @kid.id
        json.prename @kid.prename
        json.name @kid.name
        json.mentor_id @kid.mentor_id
        json.meeting_start_at get_meeting_start_time
        json.meeting_day get_meeting_day
        json.secondary_mentor_id @kid.secondary_mentor_id
        json.schedules create_schedules_nested_set @kid.schedules
      end
      json.schools School.all, :id, :display_name
    end.attributes!
  end

  protected

  def get_meeting_start_time
    return nil if @kid.meeting_start_at.blank?
    return @kid.meeting_start_at.strftime("%H:%M")
  end

  def get_meeting_day
    return nil if @kid.meeting_day.blank?
    return @kid.meeting_day
  end

  # when the user working on the kid is a teacher, it get's
  # assigned as the first teacher of the kid in creation case
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    return true if @kid.teacher.present?
    unless @kid.secondary_teacher == current_user || @kid.third_teacher == current_user
      @kid.teacher ||= current_user
    end
  end

  def track_creation_relation
    return true unless @kid.persisted?
    @kid.relation_logs.create(user_id: current_user.id,
                              role: 'creator',
                              start_at: Time.now)
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

  def kid_params
    if params[:kid].present?
      params.require(:kid).permit(
          :name, :prename, :sex, :dob, :grade, :language, :parent_country, :parent, :address,
          :city, :phone, :translator, :note, :school_id,
          :goal_1, :goal_2, :goal_3 , :goal_4, :goal_5, :goal_6, :goal_7, :goal_8, :goal_9, :goal_10,
          :goal_11, :goal_12, :goal_13, :goal_14, :goal_15, :goal_16, :goal_17, :goal_18, :goal_19,
          :goal_20, :goal_21, :goal_22, :goal_23, :goal_24, :goal_25, :goal_26, :goal_27, :goal_28,
          :goal_29, :goal_30, :goal_31, :goal_32, :goal_33, :goal_34, :goal_35,
          :simplified_schedule,
          :meeting_day, :meeting_start_at, :teacher_id, :secondary_teacher_id,
          :third_teacher_id, :mentor_id, :secondary_mentor_id, :secondary_active, :admin_id, :term,
          :exit, :exit_reason, :exit_kind, :exit_at, :checked_at,
          :coached_at, :abnormality,
          :abnormality_criticality, :todo, :inactive,
          schedules_attributes: [:day, :hour, :minute],
      )
    else
      {}
    end
  end

  # In the react-component, we need the schedules as some kind of "nested-set"
  # It is a hash where an entry set[day]["hour:minute"] is true, if that day and
  # time occurs in the array. Otherwise this key does not exist.
  def create_schedules_nested_set (schedules_array)

    schedules_set = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = {} } }
    schedules_by_day = schedules_array.group_by { |s| s.day }
    schedules_by_day.each do |day, times|
      times.each do |time|
        key = time.hour.to_s.rjust(2, '0')+':'+time.minute.to_s.rjust(2, '0')
        schedules_set[day][key] = true
      end
    end
    return schedules_set

  end

  # this form may be reached from substitutions, this is indicated
  # by a parameter substitution_id
  def prepare_substitution
    if params[:substitution_id].present?
      @substitution = Substitution.find(params[:substitution_id])
    end
  end

  def load_and_constrain_schools
    case current_user
      when Teacher
        @schools = [ current_user.school ]
        @schools_include_blank = false
      when Principal
        @schools = current_user.schools
        @schools_include_blank = false
      when Admin
        @schools = School.by_kind(:kid)
        @schools_include_blank = true
      else
        fail SecurityError.new("User #{current_user.id}")
    end
  end

  # do not let teachers and principals change the school id of foreign
  # objects not to let kids be assigned to other entities
  def intercept_school_id
    return if current_user.is_a?(Admin)

    school_id = params[:kid] && params[:kid][:school_id]
    if school_id.present?
      valid_school_ids = []
      if current_user.is_a?(Principal)
        valid_school_ids = current_user.schools.map(&:id)
      elsif current_user.is_a?(Teacher)
        valid_school_ids = [ current_user.school_id ]
      end
      unless valid_school_ids.map(&:to_s).include?(school_id)
        fail SecurityError.new("User #{current_user.id} not allowed to change school_id to #{school_id}")
      end
    end
  end
end
