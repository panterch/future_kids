class Review < ActiveRecord::Base

  default_scope :order => 'held_at DESC'

  belongs_to :kid

  def display_name
    return "Neue Gesprächsdoku" if new_record?
    "Gespräch vom #{I18n.l(held_at.to_date)}"
  end

  def human_content; content.try(:textilize); end
  def human_reason; reason.try(:textilize); end
  def human_outcome; outcome.try(:textilize); end
  def human_note; note.try(:textilize); end

end
