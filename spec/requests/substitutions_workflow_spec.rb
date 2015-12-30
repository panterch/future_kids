require 'requests/acceptance_helper'

feature 'ADMIN::CREATE:SUBSTITUTION', '
  As a admin
  I want to fill out the new substitution form
  So that I can create a new substitution

', :issue126 => true do

  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    # Frederik receives ects
    mentor = create(:mentor, ects: true, prename: 'Frederik', name: 'Haller', sex: 'm')
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
    fill_in 'substitution_start_at', with: Date.parse('2015-11-13')
    fill_in 'substitution_end_at', with: Date.parse('2015-11-15')
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