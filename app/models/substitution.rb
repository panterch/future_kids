class Substitution < ActiveRecord::Base
	validates :start_at, :end_at, :mentor, :kid, presence: true

	belongs_to :mentor
	belongs_to :secondary_mentor, class_name: 'Mentor'
	belongs_to :kid


	default_scope -> { order(:start_at) }
  scope :active, -> { where(set_inactive_at: nil) }

end
