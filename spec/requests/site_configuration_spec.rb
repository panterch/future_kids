require 'requests/acceptance_helper'

feature 'Site' do
  scenario 'should be able to edit address in page footer' do
    log_in(create(:admin))
    visit edit_site_url
    fill_in 'Adressangaben in Fusszeile', with: 'Adresse im Footer'
    click_button 'Seitenweite Konfiguration aktualisieren'
    visit root_url
    expect(page).to have_content('Adresse im Footer')
  end

  scenario 'should not allow mentors to edit configuration' do
    log_in(create(:mentor))
    expect { visit edit_site_url }.to raise_error(CanCan::AccessDenied)
  end
end
