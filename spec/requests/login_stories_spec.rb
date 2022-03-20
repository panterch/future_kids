require 'requests/acceptance_helper'

feature 'SESSION::LOGIN', '
  As a mentor
  I want to have a login form
  So that I can login

' do
  background do
    @pw = 'spec12378'
    @mentor = create(:mentor, password: @pw, password_confirmation: @pw, terms_of_use_accepted: true)
  end

  scenario 'should login the user w/ valid credentials' do
    visit new_user_session_path
    fill_in 'user_email',    with: @mentor.email
    fill_in 'user_password', with: @pw
    click_button 'Anmelden'
    expect(page).to have_content('Erfolgreich angemeldet.')
  end

  scenario 'should not login the user w/ invalid credentials' do
    visit new_user_session_path
    fill_in 'user_email',    with: @mentor.email
    fill_in 'user_password', with: 'invalid'
    click_button 'Anmelden'
    expect(page).to have_content('Ungültige Anmeldedaten')
  end

  scenario 'should not login inactive users' do
    @mentor.update_attribute(:inactive, true)
    visit new_user_session_path
    fill_in 'user_email',    with: @mentor.email
    fill_in 'user_password', with: @pw
    click_button 'Anmelden'
    expect(page).to have_content('Anmelden')
  end

  scenario 'should login only accepted users' do
    invalid_states = [:selfservice, :queued, :invited, :declined]

    invalid_states.each do |invalid_state|
      @mentor.update_attribute(:state, invalid_state)
      visit new_user_session_path
      fill_in 'user_email',    with: @mentor.email
      fill_in 'user_password', with: @pw
      click_button 'Anmelden'
      expect(page).to have_content('Anmelden')
    end

    @mentor.update_attribute(:state, :accepted)
    visit new_user_session_path
    fill_in 'user_email',    with: @mentor.email
    fill_in 'user_password', with: @pw
    click_button 'Anmelden'
    expect(page).to have_content('Schüler/innen')
    
  end
end
