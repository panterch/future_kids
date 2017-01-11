require 'requests/acceptance_helper'

feature 'Mentor index' do

  background do
    @pw = 'welcome'
    @admin1  = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw)
    @mentor1 = create(:mentor, name: 'first', prename: 'mentor', transport: 'Halbtax')
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor', transport: 'GA')
    @kid1    = create(:kid, mentor: @mentor1, meeting_day: '1')
    @kid2    = create(:kid, mentor: @mentor1, meeting_day: '2')
    @kid3    = create(:kid, mentor: @mentor1, meeting_day: '1')
    @kid4    = create(:kid, mentor: @mentor1, meeting_day: '2')
    @kid5    = create(:kid, mentor: @mentor2, meeting_day: '2')
    @kid6    = create(:kid, mentor: @mentor2, meeting_day: '2')
    log_in(@admin1)
    click_link 'Mentor/in'
  end

  scenario 'should filter mentors on meeting day without repetitions' do
    select('Montag', from: 'mentor_filter_by_meeting_day')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    select('Dienstag', from: 'mentor_filter_by_meeting_day')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    expect(page).to have_css('a', text: 'second mentor')
  end

  scenario 'filtering on meeting day should not affect other filters' do
    select('Regenbogen Kanton', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
  end

  scenario 'filtering on meeting day should interact with other filters (other chosen first)' do
    select('GA', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    select('Montag', from: 'mentor_filter_by_meeting_day')
    click_button('Filter anwenden')
    expect(page).to have_text ('0 Mentor/innen')
  end

  scenario 'filtering on meeting day should interact with other filters (other chosen last, no modification)' do
    select('Montag', from: 'mentor_filter_by_meeting_day')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    select('Halbtax', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
  end

  scenario 'filtering on meeting day should interact with other filters (other chosen last, with modification)' do
    select('Dienstag', from: 'mentor_filter_by_meeting_day')
    click_button('Filter anwenden')
    expect(page).to have_text ('2 Mentor/innen')
    expect(page).to have_css('a', text: 'first mentor')
    expect(page).to have_css('a', text: 'second mentor')
    select('GA', from: 'mentor_transport')
    click_button('Filter anwenden')
    expect(page).to have_text ('1 Mentor/innen')
    expect(page).to have_css('a', text: 'second mentor')
  end
end