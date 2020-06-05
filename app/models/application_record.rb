class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActionView::Helpers::TextHelper

  def text_format(text)
    text = 'Keine Angabe' if text.blank?
    simple_format(text)
  end

  def self.humanize_enum(enum_name, enum_value)
    I18n.t("activerecord.enums.#{enum_name.to_s.pluralize}.#{enum_value}").humanize
  end
end
