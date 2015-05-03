class Document < ActiveRecord::Base
  has_attached_file :attachment,
                    path: ':rails_root/public/system/:attachment/:id/:style/:filename',
                    url: '/system/:attachment/:id/:style/:filename'

  validates_attachment_content_type :attachment, content_type: ['application/pdf', 'application/vnd.ms-excel', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  def self.category_tree
    tree = ActiveSupport::OrderedHash.new
    Document.uniq.order(:category).pluck(:category).each do |category|
      tree[category] =
        Document.uniq
        .where(category: category)
        .where('subcategory IS NOT NULL')
        .where("subcategory <> ''")
        .order(:subcategory).pluck(:subcategory)
    end
    tree
  end

  def self.in_category(category)
    Document
      .where(category: category)
      .where("subcategory IS NULL OR subcategory = ''")
      .order(:title)
  end

  def self.in_subcategory(category, subcategory)
    Document
      .where(category: category)
      .where(subcategory: subcategory)
      .order(:title)
  end
end
