class KidsController < ApplicationController

  inherit_resources
  load_and_authorize_resource
  include ManageSchedules # edit_schedules & update_schedules

  before_filter :assign_current_teacher, :only => [:create]
  before_filter :assign_selected_mentor_schedules, :only => [:edit_schedules]
  before_filter :assign_mentor_selection, :only => [:edit_schedules]

  def index

    # for admin users, the kids view may be filtered. these code is only
    # executed for admins since else we would have to take care that no other
    # user overwrites its filter constraints by adding a certain query parameter
    # here
    if current_user.is_a?(Admin)
      # a prototyped kid is submitted with each index query. if the prototype
      # is not present, it is built here with default values
      # build a where condition out of all parameters supplied for kid
      params[:kid] ||= {}
      params[:kid][:inactive] = "0" if params[:kid][:inactive].nil?
      @kids = @kids.where(params[:kid].delete_if {|key, val| val.blank? })
      # reorder the kids according to the supplied parameter
      @kids = @kids.reorder(params['order_by']) if params['order_by']
      # provide a prototype kid for the filter form
      @kid = Kid.new(params[:kid])
    end

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !current_user.is_a?(Admin) && (1 == collection.count)
      redirect_to collection.first
    else
      index!
    end
  end

protected

  # when the user working on the kid is a teacher, it get's
  # assigned as the first teacher of the kid in creation case
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    return true if resource.teacher.present?
    return true if resource.secondary_teacher.present?
    resource.teacher = current_user
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

end
