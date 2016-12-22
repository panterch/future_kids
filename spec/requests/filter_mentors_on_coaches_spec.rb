require 'requests/acceptance_helper'

feature 'Mentor index' do

  background do
    @pw = 'welcome'
    @admin  = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw)
    @admin2 = create(:admin, name: 'second', prename: 'admin')
    @mentor = create(:mentor, name: 'first', prename: 'mentor')
    @kid1   = create(:kid, mentor: @mentor, admin: @admin)
    @kid2   = create(:kid, mentor: @mentor, admin: @admin2)
    log_in(@admin)
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
    @kid3 = create(:kid, mentor: @mentor, admin: @admin)
    @kid4 = create(:kid, mentor: @mentor, admin: @admin2)
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor')
    @kid5 = create(:kid, mentor: @mentor2, admin: @admin2)
    @kid6 = create(:kid, mentor: @mentor2, admin: @admin2)
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

end
