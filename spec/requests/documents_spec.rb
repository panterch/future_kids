require 'requests/acceptance_helper'

feature 'Document Slider', js: true do
  let!(:admin) { create(:admin) }


  background do
    log_in(admin)
    visit '/'
  end

  scenario 'expands the slider' do
    create(:document, category: 'Cat', subcategory: 'Sub', title: 'Tit')
    visit documents_path
    expect(page).to have_content('Cat')
  end

end
