class MentorMatching < ApplicationRecord
  belongs_to :mentor
  belongs_to :kid

  enum :state, { pending: 'pending',
                declined: 'declined',
                reserved: 'reserved',
                confirmed: 'confirmed' }

  after_create :send_teacher_notification
  after_save :send_mentor_notification

  attr_accessor :declined_by

  def human_state_name
    self.class.human_state_name(state)
  end

  def self.human_state_name(state)
    I18n.t(state, scope: 'activerecord.attributes.mentor_matching.states')
  end

  def human_message
    text_format(message)
  end

  def confirmed
    ActiveRecord::Base.transaction do
      kid.mentor_matchings.each do |mentor_matching|
        next if mentor_matching.id == id

        mentor_matching.declined
      end
      kid.mentor = mentor
      kid.save!
      confirmed!
    end
  end

  def declined(user = nil)
    self.declined_by = user
    declined!
  end

  private

  def send_teacher_notification
    Notifications.mentor_matching_created(self).deliver_later
  end

  def send_mentor_notification
    if saved_change_to_attribute?(:state)
      case state
      when 'reserved'
        Notifications.mentor_matching_reserved(self).deliver_later
      when 'confirmed'
        Notifications.mentor_matching_confirmed(self).deliver_later
      when 'declined'
        # declined by mentor
        if declined_by && declined_by.id == self.mentor_id
          Notifications.mentor_matching_declined_by_mentor(self).deliver_later
        else
          Notifications.mentor_matching_declined(self).deliver_later
        end
      end
    end
  end
end