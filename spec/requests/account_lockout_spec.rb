# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Account lockout' do
  scenario 'locks the account after repeated failed sign-in attempts' do
    mentor = create(:mentor)

    8.times do
      visit new_user_session_path
      fill_in 'user_email', with: mentor.email
      fill_in 'user_password', with: 'wrong-password'
      click_button 'Anmelden'
      expect(page).to have_text('Ungültige Anmeldedaten.')
    end

    # Devise's last_attempt_warning fires on the 9th failed attempt (1 before lockout)
    visit new_user_session_path
    fill_in 'user_email', with: mentor.email
    fill_in 'user_password', with: 'wrong-password'
    click_button 'Anmelden'
    expect(page).to have_text('Sie haben noch einen Versuch, bevor Ihr Account gesperrt wird.')

    visit new_user_session_path
    fill_in 'user_email', with: mentor.email
    fill_in 'user_password', with: 'wrong-password'
    click_button 'Anmelden'
    expect(page).to have_text('Ihr Account ist gesperrt.')

    visit new_user_session_path
    fill_in 'user_email', with: mentor.email
    fill_in 'user_password', with: mentor.password
    click_button 'Anmelden'
    expect(page).to have_text('Ihr Account ist gesperrt.')
  end
end
