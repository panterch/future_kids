# frozen_string_literal: true

# Read-only label/value lists on the show pages, laid out as a two-column
# CSS grid (.show-for-grid in application.scss):
#
#   = details_for @kid do |d|
#     = d.attribute :name
#     = d.attribute :school do
#       = can_link_to(@kid.school)
#     = d.association :kids do |k|
#       %li= can_link_to(k)
#
# Replaces the show_for gem, keeping its markup and value lookup: a record's
# human_<attribute> method (see ApplicationRecord) wins over the raw value.
module DetailsHelper
  def details_for(object, &)
    tag.div(capture(DetailsBuilder.new(object, self), &), class: 'show-for-grid')
  end

  class DetailsBuilder
    def initialize(object, template)
      @object = object
      @template = template
    end

    # Renders one label/value row. A block without arguments replaces the
    # value; a block with one argument renders each element of a collection
    # value into a <ul>.
    def attribute(name, label: nil, &block)
      content = if block && block.arity != 1
                  @template.capture(&block)
                else
                  format(value_of(name), &block)
                end
      blank = content.blank?
      content = I18n.t('details.blank') if blank

      @template.tag.div(class: ['show-for-row', "#{@object.model_name.param_key}_#{name}",
                                ('text-body-secondary' if blank)]) do
        @template.tag.label(label || @object.class.human_attribute_name(name), class: 'show-for-label text-muted') +
          @template.tag.div(content, class: ['show-for-value', ('text-body-secondary' if blank)])
      end
    end
    alias association attribute

    private

    def value_of(name)
      human = :"human_#{name}"
      @object.respond_to?(human) ? @object.public_send(human) : @object.public_send(name)
    end

    def format(value, &block)
      value = value.to_a if value.respond_to?(:to_ary)
      case value
      when Date, Time then I18n.l(value)
      when true then I18n.t('details.yes')
      when false then I18n.t('details.no')
      when Numeric then value.to_s
      when Array then collection(value, &block) if value.any?
      else value.presence
      end
    end

    def collection(items, &block)
      block ||= ->(item) { @template.tag.li(item) }
      @template.tag.ul(@template.safe_join(items.map { |item| @template.capture(item, &block) }),
                       class: 'list-unstyled')
    end
  end
end
