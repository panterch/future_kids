def log_in(user, _options = {})
  visit new_user_session_path
  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: user.password
  click_button 'Anmelden'
  expect(page).to have_content('Erfolgreich angemeldet')
  user
end
