class RemindersController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    params[:reminder] ||= {}
    @reminders = @reminders.active
    last_selected_school = params[:reminder][:filter_by_school_id]
    if last_selected_school.present?
      @reminders = @reminders.joins(kid: [:school])
                             .where({ kids: { school_id: last_selected_school.to_i } })
    end
    params[:reminder][:filter_by_school_id] = last_selected_school
    @reminder = Reminder.new(reminder_params)
    respond_with @reminders
  end

  # update is used to trigger the mail delivery and to set the state
  # of the reminder to delivered. it will be displayed further on reminders
  # page until it is acknowledged (which is mapped t:fallback_locationo the destroy action)
  def update
    @reminder.deliver_mail # will also set sent_at flag

    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: reminders_url, notice: "Erinnerung wird zugestellt an #{@reminder.recipient}" }
    end

  end

  # destroy is used to acknowledge reminders
  #
  # there is only a soft delete for reminders so that we do not create
  # reminders for a certain week and mentor twice. acknowledged reminders
  # are not displayed anymore
  def destroy
    @reminder.update_attribute(:acknowledged_at, Time.now)
    respond_to do |format|
      format.js
      format.html { redirect_back fallback_location: reminders_url }
    end
  end

  private

  def reminder_params
    if params[:reminder].present?
      params.require(:reminder).permit(:filter_by_school_id)
    else
      {}
    end
  end
end
