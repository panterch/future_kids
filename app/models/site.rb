# frozen_string_literal: true

class Site < ApplicationRecord
  has_one_attached :logo
  encrypts :ai_api_token

  validates :logo, content_type: %i[jpg png gif], size: { less_than: 3.megabytes }
  validates :ai_api_base_url,
            format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ },
            allow_blank: true

  def self.load
    first_or_create!
  end

  # 2x the .logo-badge img max box (120x36) so it stays sharp on HiDPI screens
  def logo_medium
    logo.variant(resize_to_limit: [240, 72]).processed
  end

  # rendered on every call (instead of stored on save) so that content saved
  # before escaping was introduced can't bring raw HTML back onto the page
  def terms_of_use_html
    return if terms_of_use_content.blank?

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true), autolink: true, tables: true
    )
    markdown.render(terms_of_use_content).html_safe # rubocop:disable Rails/OutputSafety
  end
end
