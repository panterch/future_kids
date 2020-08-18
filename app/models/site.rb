class Site < ApplicationRecord
  has_one_attached :logo
  validates :logo, content_type: ext_mimes(:jpg, :png, :gif)

  def self.load
    first_or_create!
  end

  def logo_medium
    logo.variant(resize: '440>').processed
  end
end
