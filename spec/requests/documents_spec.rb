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

  # Uses the edit form: the document already has its attachment, so the submit
  # carries no file upload (Cuprite's native click hangs on multipart posts).
  scenario 'switches a category between dropdown and free text' do
    doc = create(:document, category0: 'Cat', title: 'Document Title', attachment: file)
    visit edit_document_path(doc.id)

    expect(page).to have_select('document_category0')
    expect(page).to have_no_field('document_category0', type: 'text')

    find_by_id('document_category0').ancestor('.document_category').find('a.freetext').click
    expect(page).to have_no_select('document_category0')
    fill_in 'document_category0', with: 'Neue Kategorie'
    find("#edit_document_#{doc.id} input[type=submit]").click

    expect(page).to have_current_path(documents_path)
    expect(doc.reload.category0).to eq('Neue Kategorie')
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
