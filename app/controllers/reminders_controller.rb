# frozen_string_literal: true

class RemindersController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    @reminders = @reminders.active

    filter = reminder_params

    if filter[:filter_by_school_id].present?
      @reminders = @reminders.joins(kid: [:school])
                             .where({ kids: { school_id: filter[:filter_by_school_id].to_i } })
    end

    if filter[:filter_by_ects].present?
      @reminders = @reminders.joins(:mentor)
                             .where({ mentor: { ects: filter[:filter_by_ects] } })
    end

    @reminder = Reminder.new(filter)
    respond_with @reminders
  end

  # update is used to trigger the mail delivery and to set the state
  # of the reminder to delivered. it will be displayed further on reminders
  # page until it is acknowledged (which is mapped t:fallback_locationo the destroy action)
  def update
    @reminder.deliver_mail # will also set sent_at flag

    respond_to do |format|
      format.js
      format.html do
        redirect_back_or_to(reminders_url, notice: "Erinnerung wird zugestellt an #{@reminder.recipient}")
      end
    end
  end

  # destroy is used to acknowledge reminders
  #
  # there is only a soft delete for reminders so that we do not create
  # reminders for a certain week and mentor twice. acknowledged reminders
  # are not displayed anymore
  def destroy
    @reminder.update_attribute(:acknowledged_at, Time.zone.now)
    respond_to do |format|
      format.js
      format.html { redirect_back_or_to(reminders_url) }
    end
  end

  private

  def reminder_params
    return {} if params[:reminder].blank?

    params.expect(reminder: %i[filter_by_school_id filter_by_ects])
  end
end
