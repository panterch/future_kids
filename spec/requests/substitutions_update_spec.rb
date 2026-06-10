# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'ADMIN::UPDATE:SUBSTITUTION', '
  As a admin
  I want to find a substitution for a mentor

' do
  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) do
    create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
  end
  let!(:kid) { create(:kid, mentor: mentor_frederik) }

  before do
    create(:mentor, ects: :currently, prename: 'Melanie', name: 'Rohner', sex: 'f')
    create(:substitution, mentor: mentor_frederik, kid: kid, start_at: (Time.zone.today - 1),
                          end_at: (Time.zone.today + 10))
  end

  background do
    expect(User.first.valid_password?(admin.password)).to be(true)
    log_in(admin)
  end

  scenario 'should show button to find substitution' do
    click_link 'Ersatz'
    expect(page.status_code).to eq(200)
    expect(page).to have_button('Ersatz finden')
  end

  scenario 'should pass substitution id to show_kid_mentors_schedules' do
    click_link 'Ersatz'
    click_button 'Ersatz finden'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('Ersatzmentor*in für Abwesenheit')
    expect(page).to have_text(mentor_frederik.display_name)
  end
end
