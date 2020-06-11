class Document < ApplicationRecord
  has_one_attached :attachment
  validates :attachment, attached: true,
                         content_type: ext_mimes(:xls, :xlsx, :doc, :docx, :ods, :odt, :pdf, :xlsm, :xlsb)
  validates :title, presence: true

  def self.categories(level = 0)
    Document.pluck('category'+level.to_i.to_s).compact.uniq.sort
  end

end
