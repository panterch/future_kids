class KidsController < ApplicationController

  respond_to :html, :json

  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  before_action :cancan_prototypes, only: [:show]
  before_action :assign_current_teacher, only: [:create]
  after_action :track_creation_relation, only: [:create]

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
      params[:kid] ||= {}
      params[:kid][:inactive] = '0' if params[:kid][:inactive].nil?
      @kids = @kids.where(kid_params.to_h.delete_if { |_key, val| val.blank? })
      # reorder the kids according to the supplied parameter
      @kids = @kids.reorder(params['order_by']) if params['order_by']
      # provide a prototype for the filter form
      @kid = Kid.new(kid_params)
    end

    respond_with @kids
  end



  def show_kid_mentors_schedules
   @kid_mentor_schedules_data = Jbuilder.new do |json|
      json.mentors do
        Mentor.active.each do |mentor|
          json.set! mentor.id do
            json.id mentor.id
            json.prename mentor.prename
            json.name mentor.name
            json.sex mentor.sex
            json.ects mentor.ects
            json.kids mentor.kids, :id
            json.secondary_kids mentor.secondary_kids, :id
            json.primary_kids_school do
              if not mentor.primary_kids_school.nil?
                json.id mentor.primary_kids_school.id
              end

            end



            json.schedules create_schedules_nested_set mentor.schedules
          end
        end
      end
      json.kid do
        json.id @kid.id
        json.prename @kid.prename
        json.name @kid.name
        json.schedules create_schedules_nested_set @kid.schedules
      end
      json.schools School.all, :id, :display_name

      

    end.attributes!
  end


  protected

  # when the user working on the kid is a teacher, it get's
  # assigned as the first teacher of the kid in creation case
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    return true if @kid.teacher.present?
    @kid.teacher ||= current_user if @kid.secondary_teacher != current_user
    @kid.school ||= @kid.teacher.try(:school)
    @kid.school ||= @kid.secondary_teacher.try(:school)
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
  end

  private

  def kid_params
    if params[:kid].present?
      params.require(:kid).permit(
        :name, :prename, :sex, :dob, :grade, :language, :parent, :address,
        :city, :phone, :translator, :note, :school_id, :goal_1, :goal_2,
        :meeting_day, :meeting_start_at, :teacher_id, :secondary_teacher_id,
        :mentor_id, :secondary_mentor_id, :secondary_active, :admin_id, :term,
        :exit, :exit_reason, :exit_kind, :exit_at,
        :coached_at, :abnormality,
        :abnormality_criticality, :todo, :inactive,
        schedules_attributes: [:day, :hour, :minute]
      )
    else
      {}
    end
  end

  # In the react-component, we need the schedules as some kind of "nested-set"
  # It is a hash where an entry set[day]["hour:minute"] is true, if that day and time
  # occures in the array. otherwise this key does not exist.
  def create_schedules_nested_set (schedules_array)

    schedules_set = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = {}}}
    schedules_by_day = schedules_array.group_by {|s| s.day}
    schedules_by_day.each do |day, times|
      times.each do |time|
        key = time.hour.to_s.rjust(2, '0')+':'+time.minute.to_s.rjust(2, '0')
        schedules_set[day][key] = true
      end
    end
    return schedules_set

  end
end
