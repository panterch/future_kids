class Substitution < ActiveRecord::Base
	validates :start_at, :end_at, presence: true

	belongs_to :mentor
end
