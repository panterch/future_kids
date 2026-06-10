# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Principals as Admin' do
  background do
    log_in(create(:admin))
  end

  scenario 'should be able to create a principal' do
    create(:school)

    click_link 'SL/QUIMS'
    click_link 'Erfassen'

    fill_in 'Name', with: 'Principal Name'
    fill_in 'Vorname', with: 'Principal Vorname'
    fill_in 'E-Mail', with: 'principal@email.com'
    fill_in 'Passwort', with: '123456'
    fill_in 'Passwort Bestätigung', with: '123456'
    find('#principal_school_ids option:first-child').select_option
    click_button 'SL/QUIMS-Verantwortliche*r'

    expect(page).to have_text('principal@email.com')
  end

  scenario 'should be able assign principal to multiple schools' do
    principal = create(:principal)
    create(:school, name: 'extra-school-one')
    create(:school, name: 'extra-school-two')

    visit principal_path(principal)
    expect(page).to have_current_path(principal_path(principal))

    expect(page).to have_no_text('extra-school-one')
    expect(page).to have_no_text('extra-school-two')

    click_on 'Bearbeiten'

    select 'extra-school-one', from: 'principal_school_ids'
    select 'extra-school-two', from: 'principal_school_ids'

    click_button 'SL/QUIMS-Verantwortliche*r aktualisieren'

    expect(page).to have_text('extra-school-one')
    expect(page).to have_text('extra-school-two')
  end
end
