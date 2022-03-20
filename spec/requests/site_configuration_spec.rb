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

  scenario 'After edit terms of use other users must accept it after login' do
    @teacher = create(:teacher)
    log_in(create(:admin))
    visit edit_site_url
    fill_in 'Nutzungsbedingungen', with: 'Terms of use'
    click_button 'Seitenweite Konfiguration aktualisieren'
    click_link 'Abmelden'

    visit new_user_session_path
    fill_in 'user_email', with: @teacher.email
    fill_in 'user_password', with: @teacher.password
    click_button 'Anmelden'

    expect(page).to have_button('Nutzungsbedingungen Akzeptieren')
  end

  scenario 'User after login must accept terms of use' do
    @teacher = create(:teacher, terms_of_use_accepted: false)

    visit new_user_session_path
    fill_in 'user_email', with: @teacher.email
    fill_in 'user_password', with: @teacher.password
    click_button 'Anmelden'

    click_button 'Nutzungsbedingungen Akzeptieren'
    expect(page).to have_content('Erfolgreich angemeldet')
  end
end
