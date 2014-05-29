# shared code between kids and mentors controller to manage nested schedules
# records
module ManageSchedules

  def edit_schedules
    @week = Schedule.build_week
    # decouple schedules so include? works
    @schedules = resource.schedules.to_a
  end

  def update_schedules
    # we do not bother with the deletion / update of schedule records.  So if we
    # except a successful save we just destroy all records and create them again
    # from the submitted data.
    resource.schedules.destroy_all
    schedule_attributes =
      permitted_params[resource_request_name] && # guard against none attributes submitted
      permitted_params[resource_request_name][:schedules_attributes]
    if schedule_attributes.present?
      resource.update_attributes(:schedules_attributes => schedule_attributes)
    end
    redirect_to :action => :show
  end

end
