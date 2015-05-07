class RemindersController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    @reminders = @reminders.active
    respond_with @reminders
  end

  # update is used to trigger the mail delivery and to set the state
  # of the reminder to delivered. it will be displayed further on reminders
  # page until it is acknowledged (which is mapped to the destroy action)
  def update
    @reminder.deliver_mail # will also set sent_at flag
    redirect_to reminders_url, notice: "Erinnerung wird zugestellt an #{@reminder.recipient}"
  end

  # we only have a soft delete for reminders so that we do not create
  # reminders for a certain week and mentor twice. acknowleded reminders
  # are not displayed anymore
  def destroy
    @reminder.update_attribute(:acknowledged_at, Time.now)
    redirect_to reminders_url
  end
end
