require 'requests/acceptance_helper'

feature 'Mentor index' do

  background do
    @pw = 'welcome'
    @admin1  = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw)
    @admin2  = create(:admin, name: 'second', prename: 'admin')
    @mentor1 = create(:mentor, name: 'first', prename: 'mentor', transport: 'Halbtax', primary_kids_meeting_day: 'Dienstag')
    @kid1    = create(:kid, mentor: @mentor1, admin: @admin1)
    @kid2    = create(:kid, mentor: @mentor1, admin: @admin2)
    @kid3    = create(:kid, mentor: @mentor1, admin: @admin1)
    @kid4    = create(:kid, mentor: @mentor1, admin: @admin2)
    log_in(@admin1)
  end

  scenario 'should filter mentors on coaches' do
    click_link 'Mentor/in'
    select('first admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    select('second admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
  end

  scenario 'should filter mentors on coaches without repetitions' do
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor')
    @kid5    = create(:kid, mentor: @mentor2, admin: @admin2)
    @kid6    = create(:kid, mentor: @mentor2, admin: @admin2)
    click_link 'Mentor/in'
    select('first admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    select('second admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    expect(page).to have_css('a', text: 'second mentor')
  end

  scenario 'filtering on coaches should not affect other filters' do
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor', transport: 'GA', primary_kids_meeting_day: 'Montag')
    @kid5    = create(:kid, mentor: @mentor2, admin: @admin2)
    @kid6    = create(:kid, mentor: @mentor2, admin: @admin2)
    click_link 'Mentor/in'
    select('GA', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    select('first admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
    select('Halbtax', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    select('GA', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
    select('second admin', from: 'mentor_filter_by_coach_id')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'second mentor')
    select('', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    expect(page).to have_css('a', text: 'second mentor')
  end
end
