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

  scenario 'renders new' do
    visit new_document_path
    expect(page).to have_content('Dokument erfassen')
  end

  scenario 'renders edit' do
    doc = create(:document, category0: 'Cat', category1: 'Sub', title: 'Document Title')
    visit edit_document_path(doc.id)
    expect(page).to have_field('Titel', with: 'Document Title')
  end

end
