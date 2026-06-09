# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Teachers as Admin' do
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

    expect(page).to have_text('raffael@example.com')
  end
end
