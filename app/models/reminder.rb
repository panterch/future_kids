class Reminder < ActiveRecord::Base

  default_scope :order => 'held_at DESC, id'
  scope :active, where("reminders.acknowledged_at IS NULL")

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :kid

  validates_presence_of :kid

  # sends the reminder to the appropriate recipient
  def deliver_mail
    mail = Notifications.remind(self)
    mail.deliver
    update_attributes!(:sent_at => Time.now)
  end

  # create a reminder for the given kid and the given time
  #
  # this method does no condition checks if the reminder is really needed from
  # the business point of view.
  #
  # method looks up when the meeting should have been held for the given kid
  # in the week of time and creates a reminder according to these settings
  def self.create_for(kid, time)
    r = Reminder.new
    r.kid = kid
    r.mentor = kid.mentor
    r.secondary_mentor = kid.secondary_mentor
    r.held_at = kid.calculate_meeting_time(time)
    r.week = r.held_at.strftime('%U')
    r.year = r.held_at.year
    # the recipient of the reminder should be the active mentor
    if kid.secondary_active? and kid.secondary_mentor
      r.recipient = kid.secondary_mentor.email
    else
      r.recipient = kid.mentor.try(:email)
    end
    r.save!
    r
  end

  # scans all kids and creates reminders for kids that meet the conditions
  #
  # typically called via cron once a day
  def self.conditionally_create_reminders(time = Time.now)
    reminders_created = 0

    logger.info("Beginning reminder run, reference Date #{time}")
    logger.flush

    begin

      Kid.all.each do |kid|
        logger.info("[#{kid.id}] #{kid.display_name}: checking journal entries")
        logger.flush
        if !kid.journal_entry_due?(time)
          logger.info("[#{kid.id}] #{kid.display_name}: no entry due")
          logger.flush
          next
        end
        if kid.journal_entry_for_week(time)
          logger.info("[#{kid.id}] #{kid.display_name}: journal entry present")
          logger.flush
          next
        end
        if kid.reminder_entry_for_week(time)
          logger.info("[#{kid.id}] #{kid.display_name}: reminder entry present")
          logger.flush
          next
        end
        if kid.mentor.nil? && kid.secondary_mentor.nil?
          logger.info("[#{kid.id}] #{kid.display_name}: no mentors set")
          logger.flush
          next
        end
        reminder = Reminder.create_for(kid, time)
        logger.info("[#{kid.id}] #{kid.display_name}: created reminder [#{reminder.id}]")
        logger.flush
        reminders_created += 1
      end

      # send out admin notification when reminders were created
      if (0 < reminders_created)
        Notifications.reminders_created(reminders_created).deliver
      end

    rescue => e
      logger.error "Exception during reminder run"
      logger.error e.message
      logger.error e.backtrace.join("\n")
      logger.flush
    end

    logger.info("Created #{reminders_created} reminders, reference Date #{time}")
    logger.flush

    reminders_created
  end


end
