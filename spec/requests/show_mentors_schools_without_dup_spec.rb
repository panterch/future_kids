require 'requests/acceptance_helper'

feature 'Mentor show' do
  background do
    @pw      = 'welcome'
    @admin   = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw)
    @school1 = create(:school, name: 'School 1')
    @school2 = create(:school, name: 'School 2')
    @mentor  = create(:mentor, name: 'first', prename: 'mentor')
    @kid1    = create(:kid, mentor: @mentor, school: @school1)
    @kid2    = create(:kid, mentor: @mentor, school: @school1)
    @kid3    = create(:kid, mentor: @mentor, school: @school2)
    @kid4    = create(:kid, mentor: @mentor, school: @school2)
    log_in(@admin)
  end

  scenario 'should show mentors schools without repetitions' do
    visit mentor_path(@mentor)
    expect(page).to have_text('School 1', count: 1)
    expect(page).to have_text('School 2', count: 1)
  end
end
