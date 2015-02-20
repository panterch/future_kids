class KidsController < ApplicationController

  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  before_filter :cancan_prototypes, :only => [:show]
  before_filter :assign_current_teacher, :only => [:create]
  after_filter  :track_creation_relation, :only => [:create]
  before_filter :assign_selected_mentor_schedules, :only => [:edit_schedules]
  before_filter :assign_mentor_selection, :only => [:edit_schedules]

  def index

    if current_user.is_a?(Admin) && 'xlsx' == params[:format]
      return render xlsx: 'index'
    end

    # for admin users, the kids view may be filtered. these code is only
    # executed for admins since else we would have to take care that no other
    # user overwrites its filter constraints by adding a certain query parameter
    # here
    if current_user.is_a?(Admin)
      # a prototyped kid is submitted with each index query. if the prototype
      # is not present, it is built here with default values
      # build a where condition out of all parameters supplied for kid
      kid_params[:inactive] = "0" if kid_params[:inactive].nil?
      @kids = @kids.where(kid_params.to_h.delete_if {|key, val| val.blank? })
      # reorder the kids according to the supplied parameter
      @kids = @kids.reorder(params['order_by']) if params['order_by']
      # provide a prototype for the filter form
      @kid = Kid.new(kid_params)
    end

    respond_with @kids
  end

protected

  # when the user working on the kid is a teacher, it get's
  # assigned as the first teacher of the kid in creation case
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    return true if @kid.teacher.present?
    if @kid.secondary_teacher != current_user
      @kid.teacher ||= current_user
    end
    @kid.school  ||= @kid.teacher.try(:school)
    @kid.school  ||= @kid.secondary_teacher.try(:school)
  end

  def track_creation_relation
    return true unless @kid.persisted?
    @kid.relation_logs.create(user_id: current_user.id,
                                  role: 'creator',
                                  start_at: Time.now)
  end

  # this adds a specific behaviour for kids to the edit_schedules method -
  # one may select mentors which availability is superimpose on the kids
  # schedule form to allow a viasual selection of possible schedule entries
  def assign_selected_mentor_schedules
    @mentor_schedules = {}
    @mentor_ids = params[:mentor_ids]
    return if @mentor_ids.blank?
    selected_people = Mentor.find(@mentor_ids)
    selected_people.each do |mentor|
      @mentor_schedules[mentor.display_name] = mentor.schedules.to_a
    end
  end

  # the kids schedule editing allows the selection of mentors to display their
  # schedules in parallel. this method provides the data for the mentor
  # selection
  def assign_mentor_selection
    @mentor_groups = Mentor.mentors_grouped_by_assigned_kids
  end

  # prototypes to check abilities in menu
  def cancan_prototypes
    @cancan_journal = Journal.new(kid: @kid)
    @cancan_review = Review.new(kid: @kid)
    if current_user.is_a?(Mentor)
      @cancan_journal.mentor = current_user
    end
  end

  private

  def kid_params
    if params[:kid].present?
      params.require(:kid).permit(
        :name, :prename, :sex, :dob, :grade, :language, :parent, :address,
        :city, :phone, :translator, :note, :school_id, :goal_1, :goal_2,
        :meeting_day, :meeting_start_at, :teacher_id, :secondary_teacher_id,
        :mentor_id, :secondary_mentor_id, :secondary_active, :admin_id, :term,
        :exit, :exit_reason, :coached_at, :abnormality,
        :abnormality_criticality, :todo, :inactive,
        schedules_attributes: [:day, :hour, :minute]
      )
    else
      {}
    end
  end
end
