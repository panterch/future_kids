# frozen_string_literal: true

class Site < ApplicationRecord
  has_one_attached :logo
  encrypts :ai_api_token

  validates :logo, content_type: %i[jpg png gif], size: { less_than: 3.megabytes }
  validates :ai_api_base_url,
            format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ },
            allow_blank: true
  before_save :parse_markdown

  def self.load
    first_or_create!
  end

  def logo_medium
    logo.variant(resize_to_fit: [440, nil]).processed
  end

  private

  def parse_markdown
    return unless terms_of_use_content

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    self.terms_of_use_content_parsed = markdown.render(terms_of_use_content)
  end
end
