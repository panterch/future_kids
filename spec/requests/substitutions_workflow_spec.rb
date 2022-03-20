require 'requests/acceptance_helper'

feature 'ADMIN::CREATE:SUBSTITUTION', '
  As a admin
  I want to fill out the new substitution form
  So that I can create a new substitution

' do

  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
  }
  let!(:kid) { create(:kid, mentor: mentor_frederik)}

  background do
    expect(User.first.valid_password?(admin.password)).to eq(true)
    log_in(admin)
  end

  scenario 'should not create a new substitution without the required values' do
    click_link 'Ersatz'
    click_link 'Erfassen'
    click_button 'Ersatz erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Ersatz erfassen')
    expect(page).to have_content('muss ausgefüllt werden')
  end

  scenario 'should create a substitution with required values' do
    click_link 'Ersatz'
    click_link 'Erfassen'
    select kid.display_name, from: 'substitution[kid_id]'
    fill_in 'substitution_start_at', with: (Date.today - 10)
    fill_in 'substitution_end_at', with: (Date.today - 2)
    click_button 'Ersatz erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_content(mentor_frederik.display_name)
    expect(page).to have_content(kid.display_name)
  end

  describe 'mentor should have a quicklink for substitution and mentor and kid should be preset' do
    scenario 'contextual_link to add substitution' do
      visit mentor_path(id: mentor_frederik.id)
      find('.contextual_links_panel').click_link("Neue Abwesenheit")
      expect(page.status_code).to eq(200)
      expect(page).to have_content('Ersatz erfassen')
      expect(page).to have_content(mentor_frederik.display_name)
      expect(page).to have_content(kid.display_name)
    end
  end
end


feature 'ADMIN::UPDATE:SUBSTITUTION', '
  As a admin
  I want to find a substitution for a mentor

' do

  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
  }
  let!(:mentor_melanie) {
    create(:mentor, ects: :currently, prename: 'Melanie', name:'Rohner', sex: 'f')
  }
  let!(:kid) { create(:kid, mentor: mentor_frederik) }

  let!(:substitution) {
    create(:substitution, mentor: mentor_frederik, kid: kid, start_at: (Date.today - 1), end_at: (Date.today + 10))
  }

  background do
    expect(User.first.valid_password?(admin.password)).to eq(true)
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
    expect(page).to have_content('Ersatzmentor für Abwesenheit')
    expect(page).to have_content(mentor_frederik.display_name)
  end

end



feature 'MENTOR::SHOW:SUBSTITUTION', '
  As a mentor
  I want not be able to show/modify substitutions

' do

  let!(:mentor) {
    create(:mentor, prename: 'Mentor', name: 'Mentor', sex: 'm')
  }

  background do
    expect(User.first.valid_password?(mentor.password)).to eq(true)
    log_in(mentor)
  end

  scenario 'mentor should not be able to show substitution' do
    expect{visit substitutions_path}.to raise_error(CanCan::AccessDenied)
  end

  scenario 'mentor should not be able to see substitution-header-link' do
    expect(page).to_not have_content('Ersatz')
  end

end
