require 'requests/acceptance_helper'

feature 'Document Tree', js: true do
  let!(:admin) { create(:admin) }

  background do
    log_in(admin)
    visit '/'
  end

  scenario 'renders the tree' do
    create(:document, category0: 'Cat', category1: 'Sub', title: 'Tit')
    visit documents_path
    expect(page).to have_content('Cat')
  end

end
