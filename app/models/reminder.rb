class Reminder < ActiveRecord::Base

  default_scope :order => 'held_at DESC'

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :kid

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
    r.recipient ||= kid.secondary_mentor.try(:email)
    r.recipient ||= kid.mentor.try(:email)
    r.mentor = kid.mentor || kid.secondary_mentor
    r.secondary_mentor = kid.secondary_mentor
    r.held_at = kid.calculate_meeting_time(time)
    r.week = r.held_at.strftime('%U')
    r.year = r.held_at.year
    r.save!
    r
  end

  # scans all kids and creates reminders for kids that meet the conditions
  def self.conditionally_create_reminders(time = Time.now)
    reminders_created = 0

    Kid.all.each do |kid|
      logger.info("[#{kid.id}] #{kid.display_name}: checking journal entries")
      if !kid.journal_entry_due?(time)
        logger.info("[#{kid.id}] #{kid.display_name}: no entry due")
        next
      end
      if kid.journal_entry_for_week(time)
        logger.info("[#{kid.id}] #{kid.display_name}: journal entry present")
        next
      end
      if kid.reminder_entry_for_week(time)
        logger.info("[#{kid.id}] #{kid.display_name}: reminder entry present")
        next
      end
      if kid.mentor.nil? && kid.secondary_mentor.nil?
        logger.info("[#{kid.id}] #{kid.display_name}: no mentors set")
        next
      end
      logger.info("[#{kid.id}] #{kid.display_name}: creating reminder")
      Reminder.create_for(kid, time)
      reminders_created += 1
    end

    # send out admin notification when reminders were created
    if (0 < reminders_created)
      Notifications.reminders_created(reminders_created).deliver
    end

    reminders_created
  end

end
