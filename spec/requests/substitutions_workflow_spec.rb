require 'requests/acceptance_helper'

feature 'ADMIN::CREATE:SUBSTITUTION', '
  As a admin
  I want to fill out the new substitution form
  So that I can create a new substitution

' do

  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    mentor = create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
    mentor
  }
  let!(:kid) { 
    kid = create(:kid)
    kid.mentor = mentor_frederik
    kid
  }

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

  scenario 'should create a new kid with required values' do
    click_link 'Ersatz'
    click_link 'Erfassen'
    select mentor_frederik.display_name, from: 'substitution[mentor_id]'
    select kid.display_name, from: 'substitution[kid_id]'
    fill_in 'substitution_start_at', with: (Date.today - 10)
    fill_in 'substitution_end_at', with: (Date.today - 2)
    click_button 'Ersatz erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Ersatz anzeigen')
    expect(page).to have_content(mentor_frederik.display_name)
    expect(page).to have_content(kid.display_name)
  end

  describe 'mentor sould have a quicklink for substitution and mentor and kid sould be preset' do
    scenario 'contextual_link to add substitution' do
      visit mentor_path(id: mentor_frederik.id)
      find('#contextual_links_panel').click_link("Neue Abwesenheit")
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
    mentor = create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
    mentor
  }
  let!(:mentor_melanie) {
    mentor = create(:mentor, ects: true, prename: 'Melanie', name:'Rohner', sex: 'f')
    mentor
  }
  let!(:kid) { 
    kid = create(:kid, mentor: mentor_frederik)
    kid
  }
  let!(:substitution) { 
    substitution = create(:substitution, mentor: mentor_frederik, secondary_mentor:false, kid: kid, start_at: (Date.today - 1), end_at: (Date.today + 10))
    substitution
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

  scenario 'sould pass substitution id to show_kid_mentors_schedules' do
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
    mentor = create(:mentor, prename: 'Mentor', name: 'Mentor', sex: 'm')
    mentor
  }

  background do
    expect(User.first.valid_password?(mentor.password)).to eq(true)
    log_in(mentor)
  end

  scenario 'mentor sould not be able to show substitution' do
    expect{visit substitutions_path}.to raise_error(CanCan::AccessDenied)
  end

  scenario 'mentor sould not be able to see substitution-header-link' do
    expect(page).to_not have_content('Ersatz')
  end
  
end