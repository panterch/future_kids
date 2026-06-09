# frozen_string_literal: true

class Review < ApplicationRecord
  default_scope { order(held_at: :desc) }

  belongs_to :kid

  validates :held_at, presence: true
  validates_date :held_at, after: '2001-01-01'

  after_save :sync_fields_with_kid

  def display_name
    return 'Neue Gesprächsdoku' if new_record?
    return "Gespräch vom #{I18n.l(held_at.to_date)}" if held_at

    'Gespräch'
  end

  human_text_attributes :content, :outcome, :note, :attendee

  # coaching via phone can be recorded as check / coaching
  def sync_fields_with_kid
    return unless reason == 'Telefoncoaching'

    kid.update(
      checked_at: held_at,
      coached_at: held_at
    )
  end
end
