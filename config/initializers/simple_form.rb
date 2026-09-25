# frozen_string_literal: true

# Bootstrap 5 form markup. Forms are horizontal (col-sm-3 label, col-sm-9
# field) by default; the vertical_* wrappers are for the few inputs that sit
# on their own inside a card (e.g. the goal checkboxes in kids/_form).
SimpleForm.setup do |config|
  config.error_notification_tag = :div
  config.error_notification_class = 'alert alert-danger'
  config.button_class = 'btn btn-primary'
  config.boolean_style = :nested
  config.boolean_label_class = nil
  config.browser_validations = false
  config.collection_label_methods = [:display_name]
  config.collection_value_methods = [:id]
  config.label_text = ->(label, required, _explicit_label) { "#{required} #{label}" }

  # Bootstrap 5 only shows a field's .invalid-feedback when the input right
  # before it has .is-invalid. simple_form 5 ignores the old global
  # input_field_error_class setting, so every wrapper's :input/:label_input
  # below sets `error_class: 'is-invalid'` itself.
  feedback = lambda do |b, error_class: 'invalid-feedback'|
    b.use :error, wrap_with: { tag: 'span', class: error_class }
    b.use :hint,  wrap_with: { tag: 'p', class: 'form-text' }
  end

  text_input_components = lambda do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
  end

  config.wrappers :vertical_form, tag: 'div', class: 'mb-3' do |b|
    text_input_components.call(b)
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control', error_class: 'is-invalid'
    feedback.call(b)
  end

  config.wrappers :vertical_boolean, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: 'div', class: 'form-check' do |ba|
      ba.use :label_input, class: 'form-check-input', error_class: 'is-invalid'
      feedback.call(ba)
    end
  end

  config.wrappers :vertical_radio_and_checkboxes, tag: 'div', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, error_class: 'is-invalid'
    # the radios/checkboxes sit in their own .form-check divs, so the message
    # is never the invalid input's sibling -- force it visible with .d-block
    feedback.call(b, error_class: 'invalid-feedback d-block')
  end

  # Text-like inputs, including file inputs (the optional components only
  # apply when an input asks for them).
  config.wrappers :horizontal_form, tag: 'div', class: 'mb-3 row' do |b|
    text_input_components.call(b)
    b.use :label, class: 'col-sm-3 col-form-label text-sm-end'
    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control', error_class: 'is-invalid'
      feedback.call(ba)
    end
  end

  # .form-select gives native selects their Bootstrap 5 chevron.
  # horizontal_select_narrow_label is for selects that sit two-per-row in
  # col-sm-6 halves (kids/show_kid_mentors_schedules.html.haml), where a
  # col-sm-3 label is effectively an eighth of the row and wraps badly.
  { horizontal_select: [3, 9], horizontal_select_narrow_label: [5, 7] }.each do |name, (label_cols, input_cols)|
    config.wrappers name, tag: 'div', class: 'mb-3 row' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: "col-sm-#{label_cols} col-form-label text-sm-end"
      b.wrapper tag: 'div', class: "col-sm-#{input_cols}" do |ba|
        ba.use :input, class: 'form-select', error_class: 'is-invalid'
        feedback.call(ba)
      end
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'mb-3 row' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: 'div', class: 'col-sm-9 offset-sm-3' do |ba|
      ba.wrapper tag: 'div', class: 'form-check' do |bc|
        bc.use :label_input, class: 'form-check-input', error_class: 'is-invalid'
        feedback.call(bc)
      end
    end
  end

  config.default_wrapper = :horizontal_form
  config.wrapper_mappings = {
    check_boxes: :vertical_radio_and_checkboxes,
    radio_buttons: :vertical_radio_and_checkboxes,
    boolean: :horizontal_boolean,
    select: :horizontal_select
  }
end
