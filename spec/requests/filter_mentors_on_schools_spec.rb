require 'requests/acceptance_helper'

feature 'Mentor index' do

  background do
    @pw = 'welcome'
    @admin1  = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw, terms_of_use_accepted: true)
    @admin2  = create(:admin, name: 'second', prename: 'admin', terms_of_use_accepted: true)
    @mentor1 = create(:mentor, name: 'first', prename: 'mentor', transport: 'Halbtax', terms_of_use_accepted: true)
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor', transport: 'GA', terms_of_use_accepted: true)
    @school1 = create(:school, name: 'school1', school_kind: :primary_school)
    @school2 = create(:school, name: 'school2', school_kind: :primary_school)
    @kid1    = create(:kid, mentor: @mentor1, admin: @admin1, school: @school1)
    @kid2    = create(:kid, mentor: @mentor1, admin: @admin2, school: @school2)
    @kid3    = create(:kid, mentor: @mentor1, admin: @admin1, school: @school1)
    @kid4    = create(:kid, mentor: @mentor1, admin: @admin2, school: @school2)
    @kid5    = create(:kid, mentor: @mentor2, admin: @admin2, school: @school2)
    @kid6    = create(:kid, mentor: @mentor2, admin: @admin2, school: @school2)
    log_in(@admin1)
    click_link 'Mentor/in'
  end

  scenario 'should filter mentors on schools without repetitions' do
    select('school1', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first, mentor')
    select('school2', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first, mentor')
    expect(page).to have_css('a', text: 'second, mentor')
  end

  scenario 'filtering on schools should interact with other filters (other chosen first)' do
    select('GA', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'second, mentor')
    select('school1', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
    select('school2', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'second, mentor')
  end

  scenario 'filtering on schools should interact with other filters (other chosen last, no modification)' do
    select('school1', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first, mentor')
    select('Halbtax', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first, mentor')
  end

  scenario 'filtering on schools should interact with other filters (other chosen last, with modification)' do
    select('school2', from: 'mentor_filter_by_school_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first, mentor')
    expect(page).to have_css('a', text: 'second, mentor')
    select('first, admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
  end
end