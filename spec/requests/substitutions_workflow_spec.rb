require 'requests/acceptance_helper'

feature 'substitution', js: true, :issue126 => true do
  let(:kid) {
    kid = create(:kid)

    kid.schedules.create(day: 1, hour: 16, minute: 0)
    kid.schedules.create(day: 1, hour: 16, minute: 30)
    kid.schedules.create(day: 1, hour: 17, minute: 0)
    kid.schedules.create(day: 1, hour: 17, minute: 30)
    kid.schedules.create(day: 1, hour: 18, minute: 0)
    kid.schedules.create(day: 1, hour: 18, minute: 30)

    kid.schedules.create(day: 2, hour: 15, minute: 0)
    kid.schedules.create(day: 2, hour: 15, minute: 30)
    kid.schedules.create(day: 2, hour: 16, minute: 0)
    kid.schedules.create(day: 2, hour: 16, minute: 30)
    kid.schedules.create(day: 2, hour: 17, minute: 0)
    kid.schedules.create(day: 2, hour: 17, minute: 30)

    kid.schedules.create(day: 3, hour: 15, minute: 30)
    kid.schedules.create(day: 3, hour: 16, minute: 0)
    kid.schedules.create(day: 3, hour: 16, minute: 30)
    kid.schedules.create(day: 3, hour: 17, minute: 0)
    kid.schedules.create(day: 3, hour: 17, minute: 30)
    kid.schedules.create(day: 3, hour: 18, minute: 0)
    kid
  }
  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    # Frederik receives ects
    mentor = create(:mentor, ects: true, prename: 'Frederik', name: 'Haller', sex: 'm')
    mentor.schedules.create(day: 1, hour: 14, minute: 0)
    mentor.schedules.create(day: 1, hour: 14, minute: 30)
    mentor.schedules.create(day: 1, hour: 15, minute: 0)
    mentor.schedules.create(day: 1, hour: 15, minute: 30)
    mentor.schedules.create(day: 1, hour: 16, minute: 0)
    mentor.schedules.create(day: 1, hour: 16, minute: 30)
    mentor.schedules.create(day: 2, hour: 14, minute: 0)
    mentor.schedules.create(day: 2, hour: 14, minute: 30)
    mentor.schedules.create(day: 2, hour: 15, minute: 0)
    mentor.schedules.create(day: 2, hour: 15, minute: 30)
    mentor.schedules.create(day: 2, hour: 16, minute: 0)
    mentor.schedules.create(day: 2, hour: 16, minute: 30)
    mentor
  }
  let!(:mentor_melanie) {
    # melanie receives ects
    mentor = create(:mentor, ects: true, prename: 'Melanie', name:'Rohner', sex: 'f')
    mentor.schedules.create(day: 3, hour: 14, minute: 0)
    mentor.schedules.create(day: 3, hour: 14, minute: 30)
    mentor.schedules.create(day: 3, hour: 15, minute: 0)
    mentor.schedules.create(day: 3, hour: 15, minute: 30)
    mentor.schedules.create(day: 3, hour: 16, minute: 0)
    mentor.schedules.create(day: 3, hour: 16, minute: 30)
    mentor.schedules.create(day: 5, hour: 14, minute: 0)
    mentor.schedules.create(day: 5, hour: 14, minute: 30)
    mentor.schedules.create(day: 5, hour: 15, minute: 0)
    mentor.schedules.create(day: 5, hour: 15, minute: 30)
    mentor.schedules.create(day: 5, hour: 16, minute: 0)
    mentor.schedules.create(day: 5, hour: 16, minute: 30)
    mentor
  }
  let!(:mentor_max) {
    # max does not receive ects
    mentor =create(:mentor, ects: false, prename: 'Max', name: 'Steiner', sex: 'm')
    mentor.schedules.create(day: 1, hour: 17, minute: 0)
    mentor.schedules.create(day: 1, hour: 17, minute: 30)
    mentor.schedules.create(day: 1, hour: 18, minute: 0)
    mentor.schedules.create(day: 1, hour: 18, minute: 30)
    mentor.schedules.create(day: 1, hour: 19, minute: 0)
    mentor.schedules.create(day: 2, hour: 14, minute: 30)
    mentor.schedules.create(day: 2, hour: 15, minute: 0)
    mentor.schedules.create(day: 2, hour: 15, minute: 30)
    mentor.schedules.create(day: 2, hour: 16, minute: 0)
    mentor.schedules.create(day: 2, hour: 16, minute: 30)
    mentor.schedules.create(day: 2, hour: 17, minute: 0)
    mentor.schedules.create(day: 2, hour: 17, minute: 30)
    mentor
  }

  let!(:mentor_sarah) {

    # sarah does not receive ects
    mentor =create(:mentor, ects: false, prename: 'Sarah', name: 'Koller', sex: 'f')
    mentor.schedules.create(day: 1, hour: 17, minute: 0)
    mentor.schedules.create(day: 1, hour: 17, minute: 30)
    mentor.schedules.create(day: 1, hour: 18, minute: 0)
    mentor.schedules.create(day: 1, hour: 18, minute: 30)
    mentor.schedules.create(day: 1, hour: 19, minute: 0)
    mentor.schedules.create(day: 2, hour: 14, minute: 30)
    mentor.schedules.create(day: 2, hour: 15, minute: 0)
    mentor.schedules.create(day: 2, hour: 15, minute: 30)
    mentor.schedules.create(day: 2, hour: 16, minute: 0)
    mentor.schedules.create(day: 2, hour: 16, minute: 30)
    mentor.schedules.create(day: 2, hour: 17, minute: 0)
    mentor.schedules.create(day: 2, hour: 17, minute: 30)
    mentor
  }
  let!(:mentor_5) {create(:mentor, prename: 'Mentor 5', name: 'Other')}
  let!(:mentor_6) {create(:mentor, prename: 'Mentor 6', name: 'Other')}
  let!(:mentor_7) {create(:mentor, prename: 'Mentor 7', name: 'Other')}
  let!(:mentor_8) {create(:mentor, prename: 'Mentor 8', name: 'Other')}
  let!(:mentor_9) {create(:mentor, prename: 'Mentor 9', name: 'Other')}
  let!(:mentor_10) {create(:mentor, prename: 'Mentor 10', name: 'Other')}
  let!(:mentor_11) {create(:mentor, prename: 'Mentor 11', name: 'Other')}
  let!(:mentor_12) {create(:mentor, prename: 'Mentor 12', name: 'Other')}
  let!(:mentor_13) {create(:mentor, prename: 'Mentor 13', name: 'Other')}


  background do
    expect(User.first.valid_password?(admin.password)).to eq(true)
    log_in(admin)
  end

  describe 'mentor page' do
    scenario 'contextual_link to add substitution' do
    	visit mentor_path(id: mentor_frederik.id)
	    find('#contextual_links_panel').click_link("Neue Abwesenheit")
    end
  end
end