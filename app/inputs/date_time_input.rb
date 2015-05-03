class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options = nil)
    input_html_classes << "calendricalDate form-control"

    value = input_html_options[:value]
    value ||= object.send(attribute_name) if object.respond_to? attribute_name
    input_html_options[:value] ||= I18n.localize(value) if value.present?

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options) 

    @builder.text_field(attribute_name, merged_input_options)
  end
end
