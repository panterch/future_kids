class Comment < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  after_create :send_notification

  belongs_to :journal

  default_scope { order('id') }
  validates_presence_of :body, :by, :journal_id

  def initialize_default_values(current_user)
    self.by ||= current_user.display_name
    if (previous = previous_comment)
      self.to_teacher = previous.to_teacher
      self.to_secondary_teacher = previous.to_secondary_teacher
    end
    if (current_user.is_a?(Teacher))
      kid = self.journal.kid
      self.to_teacher ||= (kid.teacher == current_user)
      self.to_secondary_teacher ||= (kid.secondary_teacher == current_user)
    end
  end

  def display_name
    return "Neuer Kommentar" if new_record?
    return "Kommentar von #{by} am #{I18n.l(created_at.to_date)} "
  end

  # tries to find the last comment on the same journal
  def previous_comment
    return nil unless self.journal
    journal.comments.last
  end

  def recipients
    to = []
    to << self.journal.mentor.email
    kid = self.journal.kid
    to << kid.admin.try(:email)
    to << kid.teacher.try(:email) if self.to_teacher?
    to << kid.secondary_teacher.try(:email) if self.to_secondary_teacher?
    to.compact
  end

  def human_body; simple_format(body); end

protected

  def send_notification
    Notifications.comment_created(self).deliver
  end

end
