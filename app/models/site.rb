class Site < ApplicationRecord
  has_one_attached :logo
  validates :logo, content_type: [ :jpg, :png, :gif ], size: { less_than: 3.megabytes }

  def self.load
    first_or_create!
  end

  def logo_medium
    logo.variant(resize: '440>').processed
  end
end
