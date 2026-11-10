# frozen_string_literal: true

class Reminder < ApplicationRecord
  default_scope { order(held_at: :desc, id: :asc) }

  # filters of the reminders index: by the kid's school and the mentor's ects
  filter_scope :filter_by_school_id, ->(id) { joins(kid: [:school]).where(kids: { school_id: id.to_i }) }
  # an unknown ects would be cast to nil and match mentors without ects
  filter_scope :filter_by_ects, lambda { |ects|
    Mentor.ects.key?(ects.to_s) ? joins(:mentor).where(mentor: { ects: }) : none
  }
  scope :active, -> { where(reminders: { acknowledged_at: nil }) }

  belongs_to :mentor
  belongs_to :secondary_mentor, class_name: 'Mentor', optional: true
  belongs_to :kid

  # sends the reminder to the appropriate recipient
  def deliver_mail
    NotificationsMailer.remind(self).deliver_now
    update!(sent_at: Time.zone.now)
  end

  # create a reminder for the given kid and the given time
  #
  # this method does no condition checks if the reminder is really needed from
  # the business point of view.
  #
  # method looks up when the meeting should have been held for the given kid
  # in the week of time and creates a reminder according to these settings
  def self.create_for(kid, time)
    Reminder.create! do |r|
      r.kid = kid
      r.mentor = kid.mentor
      r.secondary_mentor = kid.secondary_mentor
      r.held_at = kid.calculate_meeting_time(time)
      r.week = r.held_at.strftime('%U')
      r.year = r.held_at.year
      # the recipient of the reminder should be the active mentor
      r.recipient = if kid.secondary_active? && kid.secondary_mentor
                      kid.secondary_mentor.email
                    else
                      kid.mentor&.email
                    end
    end
  end

  # scans all kids and creates reminders for kids that meet the conditions
  #
  # typically called via cron once a day
  #
  # There are different rules which decide if reminders are created or not.
  # When you have to create reminders for development make sure that you
  # - have mentors assigned to kids
  # - kids have meeting days (best at start of week) and meeting time set
  # - not all journal entries or reminders are there
  # - you pass a parameter time that is a few days after the kids meeting day
  def self.conditionally_create_reminders(time = Time.zone.now)
    logger.info("Beginning reminder run, reference Date #{time}")
    logger.flush

    reminders_created_count =
      Kid.find_each.count do |kid|
        conditionally_create_reminder_for_kid(time, kid)
      end

    # send out admin notification when reminders were created
    if reminders_created_count.positive?
      # since this is run async from cron delivery can run instantly
      NotificationsMailer.reminders_created(reminders_created_count).deliver_now
    end

    logger.info(
      "Created #{reminders_created_count} reminders, reference Date #{time}"
    )
    logger.flush

    reminders_created_count
  rescue StandardError => e
    logger.error 'Exception during reminder run'
    logger.error e.message
    logger.error e.backtrace.join("\n")
    logger.flush
  end

  def self.conditionally_create_reminder_for_kid(time, kid)
    log_preamble = "[#{kid.id}] #{kid.display_name}: "

    logger.info("#{log_preamble} checking journal entries")
    logger.flush

    log_message =
      if !kid.journal_entry_due?(time)
        'no entry due'
      elsif kid.journal_entry_for_week(time)
        'journal entry present'
      elsif kid.reminder_entry_for_week(time)
        'reminder entry present'
      elsif kid.mentor.nil?
        # a reminder belongs to the kid's mentor (reminders.mentor_id is NOT
        # NULL): for a kid with only a secondary mentor creating one raises,
        # which used to abort the whole run
        'no mentor set'
      else
        reminder = Reminder.create_for(kid, time)
        reminder_created = true
        "created reminder [#{reminder.id}]"
      end

    logger.info(log_preamble + log_message)
    logger.flush

    reminder_created
  end
end
