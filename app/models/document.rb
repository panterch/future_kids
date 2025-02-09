class Document < ApplicationRecord
  has_one_attached :attachment
  validates :attachment, attached: true,
            content_type: ['application/vnd.ms-excel',
                           'application/msword',
                           'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                           'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                           'application/pdf']
  validates :title, presence: true

  def self.categories(level = 0)
    Document.pluck('category' + level.to_i.to_s).compact.uniq.sort
  end

end
