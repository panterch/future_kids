class Site < ApplicationRecord
  has_one_attached :logo
  validates :logo, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  def logo_medium
    logo.variant(resize: '440>').processed
  end
end
