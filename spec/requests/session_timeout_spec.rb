# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Session timeout' do
  scenario 'lands on the sign-in page with a message' do
    admin = create(:admin)
    # without remember-me, which would otherwise keep the session alive
    visit new_user_session_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: admin.password
    uncheck 'Angemeldet bleiben'
    click_button 'Anmelden'
    expect(page).to have_text('Erfolgreich angemeldet')

    # Devise flashes a boolean :timedout marker next to the alert message
    allow_any_instance_of(User).to receive(:timedout?).and_return(true) # rubocop:disable RSpec/AnyInstance
    visit kids_path
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_css('#flash .alert', text: I18n.t('devise.failure.timeout'))
    expect(page).to have_button('Anmelden')
  end
end
