class Site < ApplicationRecord
  has_one_attached :logo
  validates :logo, content_type: ext_mimes(:jpg, :png, :gif)

  def logo_medium
    logo.variant(resize: '440>').processed
  end
end
