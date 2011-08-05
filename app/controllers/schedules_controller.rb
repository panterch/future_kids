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
    end
    @person_id = @person.id

    # wee combine the @week collection which holds all possible schedules with
    # the schedules found on the person to know the ids of already persisted
    # schedules in the gui
    @schedules = @person.schedules.to_a
    @week.each do |day|
      day.map! do |built|
        i = @schedules.find_index(built)
        nil == i ? built : @schedules.delete_at(i)
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
