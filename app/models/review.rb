class Review < ApplicationRecord
  include ActionView::Helpers::TextHelper

  default_scope { order('held_at DESC') }

  belongs_to :kid

  validates :kid, :held_at, presence: true
  validates_date :held_at, after: '2001-01-01'

  after_save :sync_fields_with_kid

  def display_name
    return 'Neue Gesprächsdoku' if new_record?
    return "Gespräch vom #{I18n.l(held_at.to_date)}" if held_at

    'Gespräch'
  end

  def human_content
    text_format(content)
  end

  def human_reason
    text_format(reason)
  end

  def human_outcome
    text_format(outcome)
  end

  def human_note
    text_format(note)
  end

  def human_attendee
    text_format(attendee)
  end

  # coaching via phone can be recorded as check / coaching
  def sync_fields_with_kid
    return unless reason == 'Telefoncoaching'

    kid.update(
      checked_at: held_at,
      coached_at: held_at
    )
  end
end
