require 'requests/acceptance_helper'

feature 'MentorMatchings As Mentor', js: true do

  before do
    create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher))
    create(:kid, name: 'Maria Rolf', sex: 'f', longitude: 14.1025379, latitude: 50.1478497, grade: '5', teacher: create(:teacher))
    create(:kid, name: 'Olivia Rolf', sex: 'f', longitude: 14.0474263, latitude: 50.1873213, grade: '5', teacher: create(:teacher))
  end

  describe 'mentor matching' do
    let(:mentor_user) { create(:mentor, sex: 'm') }
    before do
      log_in(mentor_user)
      visit available_kids_path
    end

    scenario 'can create matching' do
      click_link('Lehrperson anschreiben', text: 'Lehrperson anschreiben')
      fill_in 'Message', with: 'I want to mentor the kid'
      click_button('Mentor matching erstellen')
      expect(mentor_user.mentor_matchings.to_a.present?).to eq true
      expect(ActionMailer::Base.deliveries.length).to eq(1)
      visit available_kids_path
      expect(page).to have_content('Lehrperson angeschrieben')
    end
  end
end
