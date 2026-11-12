# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Account lockout' do
  def sign_in_with(email, password)
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Anmelden'
  end

  # Devise runs in paranoid mode: neither the last attempt warning nor the
  # lock is announced, as both would tell that the address has an account
  scenario 'locks the account after repeated failed sign-in attempts without telling' do
    mentor = create(:mentor)

    10.times do
      sign_in_with(mentor.email, 'wrong-password')
      expect(page).to have_text('Ungültige Anmeldedaten.')
    end
    expect(mentor.reload).to be_access_locked

    sign_in_with(mentor.email, mentor.password)
    expect(page).to have_text('Ungültige Anmeldedaten.')
    expect(page).to have_no_text('gesperrt')
  end
end
