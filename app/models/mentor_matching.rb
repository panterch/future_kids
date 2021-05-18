class MentorMatching < ApplicationRecord
  belongs_to :mentor
  belongs_to :kid

  enum state: { pending: 'pending',
                accepted: 'accepted',
                declined: 'declined',
                reserved: 'reserved',
                confirmed: 'confirmed' }

  after_create :send_notification

  private

  def send_notification
    Notifications.mentor_matching_created(self).deliver_now
  end
end