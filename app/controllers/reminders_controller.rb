# frozen_string_literal: true

class RemindersController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index

  def index
    @reminders = filter_index(@reminders, reminder_params)
    return if performed?

    @reminders = @reminders.active
    preload_rows
    respond_with @reminders
  end

  # update is used to trigger the mail delivery and to set the state
  # of the reminder to delivered. it will be displayed further on reminders
  # page until it is acknowledged (which is mapped to the destroy action)
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
    @reminder.update!(acknowledged_at: Time.zone.now)
    respond_to do |format|
      format.js
      format.html { redirect_back_or_to(reminders_url) }
    end
  end

  private

  # each row shows the kid, both mentors' avatars and the kid's latest journal
  # date. the dates (kid_id => held_at) come from one grouped query instead of
  # one query per row. reorder: the Journal default scope orders by held_at,
  # which a grouped query rejects
  def preload_rows
    @reminders = @reminders.includes(:kid, mentor: { photo_attachment: :blob },
                                           secondary_mentor: { photo_attachment: :blob })
    @last_journal_dates = Journal.where(kid_id: @reminders.map(&:kid_id)).reorder(nil)
                                 .group(:kid_id).maximum(:held_at)
  end

  def reminder_params
    return {} if params[:reminder].blank?

    params.expect(reminder: %i[filter_by_school_id filter_by_ects])
  end
end
