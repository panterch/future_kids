# frozen_string_literal: true

class BootFormBuilder < SimpleForm::FormBuilder
  def buttons(*args, &block)
    @template.content_tag 'div', class: 'mb-3' do
      button(:submit, *args, &block)
    end
  end
end
