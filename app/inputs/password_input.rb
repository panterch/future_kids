class PasswordInput < SimpleForm::Inputs::PasswordInput
  def input(wrapper_options = nil)
    input_html_options[:autocomplete] ||= 'off'

    super
  end
end
