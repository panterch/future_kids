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

  scenario 'should show teachers reviews when site configuration allows it' do
    Site.load.update!(teachers_can_access_reviews: true)
    @teacher = create(:teacher)
    create(:kid, name: 'last1', prename: 'first1', teacher: @teacher)
    log_in(@teacher)
    click_link 'Schüler/in'
    click_link 'last1, first1'
    expect(page).to have_css('h1', text: 'last1, first1')
    expect(page).to have_css('h2', text: 'Gesprächsdokumentationen')
  end
end
