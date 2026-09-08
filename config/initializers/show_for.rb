# frozen_string_literal: true

# Use this setup block to configure all options available in ShowFor.
ShowFor.setup do |config|
  # The tag which wraps show_for calls.
  config.show_for_tag = :div

  # The DOM class set for show_for tag. Default is nil
  # Turns the whole show_for block into a CSS grid (see application.scss)
  # so the label column shrinks to fit its content instead of using a
  # hardcoded Bootstrap column fraction.
  config.show_for_class = 'show-for-grid'

  # The tag which wraps each attribute/association call. Default is :p.
  # display: contents (see application.scss) lets the label/value below
  # drop straight into the show-for-grid's columns.
  config.wrapper_tag = :div
  config.wrapper_class = 'show-for-row'

  # The tag used to wrap each label. Default is :strong.
  config.label_tag = :label
  config.label_class = 'show-for-label text-muted'

  # The tag used to wrap each content (value). Default is nil.
  config.content_tag = :div
  config.content_class = 'show-for-value'

  # The DOM class set for blank content tags. Default is "blank".
  config.blank_content_class = 'no_content'

  # Skip blank attributes instead of generating with a default message. Default is false.
  # config.skip_blanks = true

  # The separator between label and content. Default is "<br />".
  config.separator = ''

  # The tag used to wrap collections. Default is :ul.
  config.collection_tag = :ul
  config.collection_class = 'list-unstyled'

  # The default iterator to be used when invoking a collection/association.
  # config.default_collection_proc = lambda { |value| "<li>#{ERB::Util.h(value)}</li>".html_safe }

  # The default format to be used in I18n when localizing a Date/Time.
  # config.i18n_format = :default

  # Whenever a association is given, the first method in association_methods
  # in which the association responds to is used to retrieve the association labels.
  # config.association_methods = [ :name, :title, :to_s ]

  # If you want to wrap the text inside a label (e.g. to append a semicolon),
  # specify label_proc - it will be automatically called, passing in the label text.
  # config.label_proc = lambda { |l| l + ":" }
end
