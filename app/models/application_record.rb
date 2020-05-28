class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActionView::Helpers::TextHelper

  def text_format(text)
    text = 'Keine Angabe' if text.blank?
    simple_format(text)
  end

  def self.ext_mimes(*extensions)
    extensions.flat_map do |ext|
        MIME::Types.select { |type| type.extensions.include?(ext.to_s) }
    end.map(&:to_s)
  end
end
