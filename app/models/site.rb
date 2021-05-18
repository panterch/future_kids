class Site < ApplicationRecord
  has_one_attached :logo
  validates :logo, content_type: [ :jpg, :png, :gif ], size: { less_than: 3.megabytes }
  before_save :parse_markdown


  def self.load
    first_or_create!
  end

  def logo_medium
    logo.variant(resize: '440>').processed
  end

  private 

  def parse_markdown
    if terms_of_use_content
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      self.terms_of_use_content_parsed = markdown.render(terms_of_use_content)
    end
  end

end
