class Document < ApplicationRecord
  has_one_attached :attachment
  validates :attachment, attached: true,
                         content_type: document_content_types
  validates :title, presence: true

  def self.categories(level = 0)
    Document.pluck('category'+level.to_i.to_s).compact.uniq.sort
  end

end
