# shared code between kids and mentors controller to manage nested schedules
# records
module ManageSchedules
  extend ActiveSupport::Concern
  include ResourceHelpers

  included do
    before_action :alias_as_resource
  end

  def edit_schedules
    @week = Schedule.build_week
    # decouple schedules so include? works
    @schedules = @resource.schedules.to_a
  end

  def update_schedules
    # we do not bother with the deletion / update of schedule records.  So if we
    # except a successful save we just destroy all records and create them again
    # from the submitted data.
    @resource.schedules.destroy_all
    schedule_attributes =
      resource_params && # guard against none attributes submitted
      resource_params[:schedules_attributes]
    if schedule_attributes.present?
      @resource.update(schedules_attributes: schedule_attributes)
    end
    redirect_to action: :show
  end
end
