class Comment < ApplicationRecord
  include ActionView::Helpers::TextHelper

  after_create :send_notification

  belongs_to :journal
  belongs_to :created_by, class_name: 'User'

  default_scope { order('id') }
  validates_presence_of :body, :by, :journal_id

  def initialize_default_values(current_user)
    self.created_by = current_user
    self.by ||= current_user.display_name
    if (previous = previous_comment)
      self.to_teacher = previous.to_teacher
      self.to_secondary_teacher = previous.to_secondary_teacher
      self.to_third_teacher = previous.to_third_teacher
    end
    if current_user.is_a?(Teacher)
      kid = journal.kid
      self.to_teacher ||= (kid.teacher == current_user)
      self.to_secondary_teacher ||= (kid.secondary_teacher == current_user)
      self.to_third_teacher ||= (kid.third_teacher == current_user)
    end
  end

  def display_name
    return 'Neuer Kommentar' if new_record?
    "Kommentar von #{by} am #{I18n.l(created_at.to_date)} "
  end

  # tries to find the last comment on the same journal
  def previous_comment
    return nil unless journal
    journal.comments.last
  end

  def recipients
    to = []
    to << journal.mentor.email
    kid = journal.kid
    to << kid.admin&.email
    to << kid.teacher&.email if self.to_teacher?
    to << kid.secondary_teacher&.email if self.to_secondary_teacher?
    to << kid.third_teacher&.email if self.to_third_teacher?

    # do not send emails out to the original creator
    to.delete(self.created_by.try(:email))
    to.compact
  end

  def human_body
    text_format(body)
  end

  protected

  def send_notification
    Notifications.comment_created(self).deliver_now
  end
end
