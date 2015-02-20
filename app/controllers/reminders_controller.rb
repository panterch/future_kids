class RemindersController < ApplicationController

  load_and_authorize_resource
  include CrudActions

  def index
    @reminders = @reminders.active
    respond_with @reminders
  end

  # update is used to trigger the mail delivery
  def update
    @reminder.deliver_mail
    update!(:notice => "Erinnerung wird zugestellt an #{@reminder.recipient}") do
      reminder_url
    end
  end

  def destroy
    @reminder.update_attribute(:acknowledged_at, Time.now)
    redirect_to reminder_url
  end

end
