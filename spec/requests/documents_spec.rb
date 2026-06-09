# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Document Tree', :js do
  let!(:admin) { create(:admin) }
  let(:file) { fixture_file_upload('gespraechsdoku.pdf', 'application/pdf') }

  include ActionDispatch::TestProcess::FixtureFile

  background do
    log_in(admin)
    visit '/'
  end

  scenario 'renders the tree' do
    create(:document, category0: 'Cat', category1: 'Sub', title: 'Tit', attachment: file)
    visit documents_path
    expect(page).to have_text('Cat')
  end

  scenario 'renders new' do
    visit new_document_path
    expect(page).to have_text('Dokument erfassen')
  end

  scenario 'renders edit' do
    doc = create(:document, category0: 'Cat', category1: 'Sub', title: 'Document Title', attachment: file)
    visit edit_document_path(doc.id)
    expect(page).to have_field('Titel', with: 'Document Title')
  end

  scenario 'deletes a document via the tree' do
    doc = create(:document, category0: 'Cat', title: 'To Delete', attachment: file)
    visit documents_path
    find('.list-group-item', text: 'Cat').click
    find('.list-group-item', text: 'To Delete').click
    accept_confirm { find_by_id('tree_delete_node').click }
    expect(page).to have_current_path(documents_path)
    expect(Document.exists?(doc.id)).to be false
  end
end
