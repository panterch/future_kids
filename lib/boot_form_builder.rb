class BootFormBuilder < SimpleForm::FormBuilder
  def buttons(*args, &block)
    @template.content_tag 'div', class: 'form-groups' do
      @template.content_tag 'div', class: ['col-sm-offset-3', 'col-sm-9'] do
        button(:submit, *args, &block)
      end
    end
  end
end
