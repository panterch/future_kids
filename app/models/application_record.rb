class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActionView::Helpers::TextHelper

  def text_format(text)
    text = 'Keine Angabe' if text.blank?
    simple_format(text)
  end

  def self.human_text_attributes(*attrs)
    attrs.each do |attr|
      define_method(:"human_#{attr}") { text_format(send(attr)) }
    end
  end

  def self.human_time_attributes(*attrs)
    attrs.each do |attr|
      define_method(:"human_#{attr}") { I18n.l(send(attr), format: :time) if send(attr) }
    end
  end

  def self.human_enum_attributes(mapping)
    mapping.each do |attr, scope|
      define_method(:"human_#{attr}") do
        value = send(attr)
        return '' if value.blank?

        I18n.t(value, scope: scope)
      end
    end
  end

  def self.human_rails_enum_attributes(*attrs)
    attrs.each do |attr|
      define_method(:"human_#{attr}") do
        value = send(attr)
        return nil unless value

        self.class.humanize_enum(attr, value)
      end
    end
  end

  def self.humanize_enum(enum_name, enum_value)
    I18n.t("activerecord.enums.#{enum_name.to_s.pluralize}.#{enum_value}")
  end
end
