# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Terms of use' do
  scenario 'are linked in the footer of the login page and readable without login' do
    Site.load.update!(terms_of_use_content: "# Regeln\n\nBitte **fair** bleiben.")
    visit new_user_session_path
    click_link 'Nutzungsbedingungen'
    expect(page).to have_css('h1', text: 'Regeln')
    expect(page).to have_css('strong', text: 'fair')
  end

  scenario 'are not linked and not found when empty' do
    Site.load.update!(terms_of_use_content: '')
    visit new_user_session_path
    expect(page).to have_no_link('Nutzungsbedingungen')
    visit terms_of_use_path
    expect(page.status_code).to eq(404)
  end
end
