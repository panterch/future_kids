class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActionView::Helpers::TextHelper

  def text_format(text)
    text = 'Keine Angabe' if text.blank?
    simple_format(text)
  end

  def self.document_content_types
    %w[xls xlsx doc docx ods odt pdf xlsm xlsb].flat_map do |ext|
      MIME::Types.select { |type| type.extensions.include?(ext) }
    end.map(&:to_s)
  end
end
