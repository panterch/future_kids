require 'requests/acceptance_helper'

feature 'reminders index' do
  background do
    @admin  = create(:admin, prename: 'admin', terms_of_use_accepted: true)
    @school1 = create(:school, name: 'school1')
    @school2 = create(:school, name: 'school2')
    @kid1 = create(:kid, school: @school1, name: 'reminder1 kid')
    @reminder1 = create(:reminder, kid: @kid1)
    @kid2 = create(:kid, school: @school2, name: 'reminder2 kid')
    @reminder2 = create(:reminder, kid: @kid2)
    log_in(@admin)
    click_link 'Erinnerung'
  end

  scenario 'Should display filter reminders by school' do
    expect(page).to have_css('a', text: @reminder1.kid.name)
    expect(page).to have_css('a', text: @reminder2.kid.name)
    select('school1', from: 'reminder_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_css('a', text: @reminder1.kid.name)
    expect(page).not_to have_text @reminder2.kid.name
    select('school2', from: 'reminder_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).not_to have_text (@reminder1.kid.name)
  end

  scenario 'Should keep filter for reminders after update' do
    expect(page).to have_text (@reminder1.kid.name)
    select('school2', from: 'reminder_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_select('reminder_filter_by_school_id', selected: 'school2')
    expect(page).not_to have_text (@reminder1.kid.name)
    click_button('Zustellen')
    expect(page).to have_select('reminder_filter_by_school_id', selected: 'school2')
    expect(page).to have_text 'Erinnerung wird zugestellt'
    expect(page).not_to have_text @reminder1.kid.name
    expect(page).to have_text @reminder2.kid.name
    click_button('Quittieren')
    expect(page).to have_select('reminder_filter_by_school_id', selected: 'school2')
    expect(page).not_to have_text @reminder1.kid.name
    expect(page).not_to have_text @reminder2.kid.name
  end

end
