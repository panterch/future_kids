class Review < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  default_scope { order('held_at DESC') }

  belongs_to :kid

  validates_presence_of :kid, :held_at

  def display_name
    return "Neue Gesprächsdoku" if new_record?
    return "Gespräch vom #{I18n.l(held_at.to_date)}" if held_at
    "Gespräch"
  end

  def human_content;  text_format(content); end
  def human_reason;   text_format(reason); end
  def human_outcome;  text_format(outcome); end
  def human_note;     text_format(note); end
  def human_attendee; text_format(attendee); end

end
