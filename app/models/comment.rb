class Comment < ActiveRecord::Base
  attr_accessible :body, :by
  after_create :send_notification

  belongs_to :journal

  default_scope :order => 'id'
  validates_presence_of :body, :by, :journal_id

  def display_name
    return "Neuer Kommentar" if new_record?
    return "Kommentar vom #{I18n.l(created_at.to_date)} von #{by}"
  end

protected

  def send_notification
    Notifications.comment_created(self).deliver
  end

end
