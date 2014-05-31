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

  def human_content;  simple_format(content); end
  def human_reason;   simple_format(reason); end
  def human_outcome;  simple_format(outcome); end
  def human_note;     simple_format(note); end
  def human_attendee; simple_format(attendee); end

end
