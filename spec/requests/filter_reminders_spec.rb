require 'requests/acceptance_helper'

feature 'reminders index' do
  background do
    @admin  = create(:admin, prename: 'admin')
    @school1 = create(:school, name: 'school1')
    @school2 = create(:school, name: 'school2')
    @kid1 = create(:kid, school: @school1, name: 'reminder1 kid')
    @reminder1 = create(:reminder, kid: @kid1)
    @kid2 = create(:kid, school: @school2, name: 'reminder2 kid')
    @reminder2 = create(:reminder, kid: @kid2)
    log_in(@admin)
    click_link 'Erinnerung'
  end

  scenario 'Should display all active reminders by default' do
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
end
