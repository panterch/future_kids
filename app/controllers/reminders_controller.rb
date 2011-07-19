class RemindersController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    @reminders = @reminders.active
    index!
  end

  # update is used to trigger the mail delivery
  def update
    resource.deliver_mail
    update!(:notice => "Erinnerung wird zugestellt an #{resource.recipient}") do
      collection_url
    end
  end

  def destroy
    resource.update_attribute(:acknowledged_at, Time.now)
    redirect_to collection_url
  end

end
