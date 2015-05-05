require 'requests/acceptance_helper'

feature 'ADMIN::UPDATE:SCHOOL', '
    As an admin
    I want to modify an existing school
  'do
    background do
      @pw = 'welcome'
      @admin = create(:admin, password: @pw, password_confirmation: @pw)
      log_in(@admin)
  end

  scenario 'should be able to modify an existing school' do
      click_button 'Bearbeiten'
      fill_in 'Name', with: 'School name'
      fill_in 'Strasse, Nr.', with: 'street'
      click_button 'Schule aktualisieren'
      expect(page.status_code).to eq(200)
      expect(page).to have_content('Schule anzeigen')
  end
end
