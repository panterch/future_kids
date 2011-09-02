class SchedulesController < ApplicationController

  before_filter :authorize_admin

  def index
    @week = Schedule.build_week
    if params[:mentor_id]
      @person = Mentor.find(params[:mentor_id]) 
      @person_type = 'User'
    end
    if params[:kid_id]
      @person = Kid.find(params[:kid_id])
      @person_type = 'Kid'
      @mentor_groups = Mentor.mentors_grouped_by_assigned_kids
      @mentor_ids = params[:mentor_ids]
      @selected_people = Mentor.find(@mentor_ids) unless @mentor_ids.blank?
    end
    @person_id = @person.id

    # we combine the @week collection which holds all possible schedules with
    # the schedules found on the person to know the ids of already persisted
    # schedules in the gui.
    # After this, week is a combination of newly built records and already
    # persisted and associated records. When a new record get's created the data
    # from the built-only schedule is used and a persisted one is created
    # (action create in this controller).
    @schedules = @person.schedules.to_a
    @week.each do |day|
      day.map! do |built|
        i = @schedules.find_index(built)
        nil == i ? built : @schedules.delete_at(i)
      end
    end
    # mark the schedules with the data of any selected mentor: the weeks entries
    # can hold mentor_tags which are displayed on the calendar. these are
    # highlighted to represent the matches between the different calendars.
    (@selected_people || []).each do |mentor|
      mentor_schedules = mentor.schedules.to_a
      @week.flatten.each do |schedule|
        next unless mentor_schedules.include?(schedule)
        schedule.mentor_tags << mentor.display_name
      end
    end
  end

  def create
    @schedule = Schedule.create!(params[:schedule])
    render :text => @schedule.id
  end

  def destroy
    Schedule.find(params[:id]).destroy
    render :nothing => true
  end

protected

  def authorize_admin
    return true if current_user.is_a?(Admin)
    raise SecurityError.new("access denied for user #{current_user.id}")
  end



end
