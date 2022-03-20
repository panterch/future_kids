require 'requests/acceptance_helper'

feature 'Principals as Admin' do
  background do
    log_in(create(:admin))
  end

  scenario 'should be able to create a principal' do
    school_1 = create(:school)

    click_link 'SL/QUIMS'
    click_link 'Erfassen'

    fill_in 'Name', with: 'Principal Name'
    fill_in 'Vorname', with: 'Principal Vorname'
    fill_in 'E-Mail', with: 'principal@email.com'
    fill_in 'Passwort', with: '123456'
    fill_in 'Passwort Bestätigung', with: '123456'
    find('#principal_school_ids option:first-child').select_option
    click_button 'SL/QUIMS-Verantwortliche/r'

    expect(page).to have_content('principal@email.com')
  end

  scenario 'should be able assign principal to multiple schools' do
    principal = create(:principal)
    school_1 = create(:school, name: "extra-school-one")
    school_2 = create(:school, name: "extra-school-two")

    visit principal_path(principal)

    expect(page).to_not have_content('extra-school-one')
    expect(page).to_not have_content('extra-school-two')

    click_on 'Bearbeiten'

    page.all(:css, '#principal_school_ids option').each do |option|
        option.select_option
    end

    click_button 'SL/QUIMS-Verantwortliche/r aktualisieren'

    expect(page).to have_content('extra-school-one')
    expect(page).to have_content('extra-school-two')
  end
end
