class MentorMatching < ApplicationRecord
  belongs_to :mentor
  belongs_to :kid

  enum state: { pending: 'pending',
                accepted: 'accepted',
                declined: 'declined',
                reserved: 'reserved',
                confirmed: 'confirmed' }

  after_create :send_teacher_notification
  after_save :send_mentor_notification

  def human_state_name
    self.class.human_state_name(state)
  end

  def self.human_state_name(state)
    I18n.t(state, scope: 'activerecord.attributes.mentor_matching.states')
  end

  private

  def send_teacher_notification
    Notifications.mentor_matching_created(self).deliver_now
  end

  def send_mentor_notification
    if saved_change_to_attribute?(:state)
      if reserved?
        Notifications.mentor_matching_reserved(self).deliver_now
      elsif declined?
        Notifications.mentor_matching_declined(self).deliver_now
      end
    end
  end
end