require 'requests/acceptance_helper'

feature 'ADMIN::CREATE:TEACHER', '
    As an admin
    I want to create a teacher
  'do
    background do
      log_in(create(:admin))
  end

  scenario 'should be able to create a teacher' do
      click_link 'Lehrperson'
      click_link 'Erfassen'

      fill_in 'Name', with: 'Raffael'
      fill_in 'Vorname', with: 'Fibbioli'
      fill_in 'E-Mail', with: 'raffael@example.com'
      fill_in 'Passwort', with: '123456'
      fill_in 'Passwort Bestätigung', with: '123456'
      click_button 'Lehrperson erstellen'

      expect(page).to have_content('raffael@example.com')
      
  end

end