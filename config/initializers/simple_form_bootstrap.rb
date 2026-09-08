# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.error_notification_class = 'alert alert-danger'
  config.button_class = 'btn btn-primary'
  config.boolean_label_class = nil
  config.input_field_error_class = 'is-invalid'

  config.wrappers :vertical_form, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'form-label'

    b.use :input, class: 'form-control'
    b.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
  end

  config.wrappers :vertical_file_input, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :readonly
    b.use :label, class: 'form-label'

    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
  end

  config.wrappers :vertical_boolean, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: 'div', class: 'form-check' do |ba|
      ba.use :label_input, class: 'form-check-input'
      ba.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
    end
  end

  config.wrappers :vertical_radio_and_checkboxes, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
  end

  config.wrappers :inline_form, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'visually-hidden'

    b.use :input, class: 'form-control'
    b.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
  end

  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :vertical_form
  config.wrapper_mappings = {
    check_boxes: :vertical_radio_and_checkboxes,
    radio_buttons: :vertical_radio_and_checkboxes,
    file: :vertical_file_input,
    boolean: :vertical_boolean
  }
end
