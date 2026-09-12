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

    b.use :input, class: 'form-control'
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

  config.wrappers :horizontal_form, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label text-sm-end'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
    end
  end

  # adds .form-select so native selects get their Bootstrap 5 chevron again
  # instead of looking like a plain text field
  config.wrappers :horizontal_select, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label text-sm-end'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-select'
      ba.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
    end
  end

  # Same as horizontal_select, but a wider label column -- for selects that
  # sit two-per-row in col-sm-6 halves (see
  # kids/show_kid_mentors_schedules.html.haml), where the default col-sm-3
  # label is effectively an eighth of the row and wraps badly, while the
  # short option values (a weekday, a time, a name) don't need col-sm-9.
  config.wrappers :horizontal_select_narrow_label, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'col-sm-5 col-form-label text-sm-end'

    b.wrapper tag: 'div', class: 'col-sm-7' do |ba|
      ba.use :input, class: 'form-select'
      ba.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: 'div', class: 'col-sm-9 offset-sm-3' do |ba|
      ba.wrapper tag: 'div', class: 'form-check' do |bc|
        bc.use :label_input, class: 'form-check-input'
        bc.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
        bc.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
      end
    end
  end

  config.wrappers :horizontal_file_input, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label text-sm-end'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'invalid-feedback' }
      ba.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
    end
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
  config.default_wrapper = :horizontal_form
  config.wrapper_mappings = {
    check_boxes: :vertical_radio_and_checkboxes,
    radio_buttons: :vertical_radio_and_checkboxes,
    file: :horizontal_file_input,
    boolean: :horizontal_boolean,
    select: :horizontal_select
  }
end
