require 'requests/acceptance_helper'

feature 'Self registrations' do
  background do
    create(:admin)
    create(:school, name: 'Teacher school', school_kind: :primary_school)
    create(:school, name: 'Mentor school', school_kind: :high_school)
    Site.load.update(public_signups_active: true)
  end
  scenario 'redirect to admin if already logged in' do
    log_in(create(:admin))
    visit new_self_registration_path
    expect(current_path).to eq root_path
  end

  scenario 'self register teacher' do
    visit new_self_registration_path

    click_link 'Lehrer/in'

    fill_in 'Name', with: 'Raffael'
    fill_in 'Vorname', with: 'Fibbioli'
    fill_in 'E-Mail', with: 'raffael@example.com'
    fill_in 'Telefon', with: '123123123'
    check 'terms_of_use_accepted'


    expect(page).to have_link('Nutzungsbedingungen', href: terms_of_use_self_registrations_path)
    expect(find_link('Nutzungsbedingungen')[:target]).to eq('__blank')

    expect(page).to have_select('Schule', options: ['Teacher school'])

    click_button 'Lehrperson erstellen'

    expect(page).to have_content 'Registrierung erfolgreich'
    expect(page).to have_content 'Sie werden demnächst benachrichtigt, wenn Ihr Konto aktiviert wurde.'
    expect(Teacher.count).to eq 1
  end

  scenario 'self register mentor' do
    visit new_self_registration_path

    click_link 'Mentor/in'

    fill_in 'Name', with: 'Raffael'
    fill_in 'Vorname', with: 'Fibbioli'
    fill_in 'E-Mail', with: 'raffael@example.com'
    fill_in 'Telefon', with: '123123123'
    page.select 'weiblich', from: 'Geschlecht'
    fill_in 'Strasse, Nr.', with: 'example strasse'
    fill_in 'PLZ, Ort', with: '12345'
    check 'terms_of_use_accepted'

    expect(page).to have_link('Nutzungsbedingungen', href: terms_of_use_self_registrations_path)
    expect(find_link('Nutzungsbedingungen')[:target]).to eq('__blank')

    expect(page).to have_select('Schule', options: ['Mentor school'])

    click_button 'Mentor/in erstellen'

    expect(page).to have_content 'Registrierung erfolgreich'
    expect(page).to have_content 'Sie erhalten demnächst eine Einladung zum Vorstellungsgespräch.'
    expect(Mentor.count).to eq 1
  end

  scenario "terms of conditions" do
    visit terms_of_use_self_registrations_path

    expect(page).to have_content Site.load.terms_of_use_content_parsed
  end
end