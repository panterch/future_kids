class StringInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:autocomplete] = 'off' if @input_type == :email

    super
  end
end
