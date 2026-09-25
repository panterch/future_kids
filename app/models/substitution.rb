# frozen_string_literal: true

class Substitution < ApplicationRecord
  validates :start_at, :end_at, presence: true
  validates :start_at, :end_at, comparison: { greater_than: Date.new(2001, 1, 1) }, allow_blank: true

  belongs_to :mentor
  belongs_to :secondary_mentor, class_name: 'Mentor', optional: true
  belongs_to :kid

  default_scope -> { order(:start_at) }
  scope :active, -> { where(inactive: false) }

  human_text_attributes :comments
end
