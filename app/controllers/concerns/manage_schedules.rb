# frozen_string_literal: true

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
    # from the submitted data. Both steps run in one transaction: if the save
    # fails (the whole record is validated, not only the schedules), the old
    # schedules are kept.
    schedule_attributes = resource_params&.dig(:schedules_attributes) # guard against none attributes submitted
    saved = false
    @resource.transaction do
      @resource.schedules.destroy_all
      # nothing submitted means all slots were unchecked: the schedule stays empty
      saved = schedule_attributes.blank? || @resource.update(schedules_attributes: schedule_attributes)
      raise ActiveRecord::Rollback unless saved
    end
    flash[:alert] = t('flash.schedules_not_saved') unless saved
    redirect_to action: :show
  end
end
