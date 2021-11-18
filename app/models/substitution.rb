class Substitution < ApplicationRecord
  validates :start_at, :end_at, :mentor, :kid, presence: true
  validates_date :start_at, :end_at, after: '2001-01-01'

  belongs_to :mentor
  belongs_to :secondary_mentor, class_name: 'Mentor', optional: true
  belongs_to :kid

  default_scope -> { order(:start_at) }
  scope :active, -> { where(inactive: false) }

  def human_comments
    text_format(comments)
  end
end
