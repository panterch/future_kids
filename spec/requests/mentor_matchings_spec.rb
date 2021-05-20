require 'requests/acceptance_helper'

feature 'MentorMatchings As Mentor', js: true do

  before do
    create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher))
    create(:kid, name: 'Maria Rolf', sex: 'f', longitude: 14.1025379, latitude: 50.1478497, grade: '5', teacher: create(:teacher))
    create(:kid, name: 'Olivia Rolf', sex: 'f', longitude: 14.0474263, latitude: 50.1873213, grade: '5', teacher: create(:teacher))
  end

  describe 'mentor matching' do
    let(:mentor) { create(:mentor, sex: 'm') }
    let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', teacher: create(:teacher)) }
    let(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'reserved') }
    before do
      log_in(mentor)
      visit available_kids_path
    end

    scenario 'can create matching' do
      click_link('Lehrperson anschreiben', text: 'Lehrperson anschreiben')
      fill_in 'Nachricht', with: 'I want to mentor the kid'
      click_button('Mentor matching erstellen')
      expect(mentor.mentor_matchings.to_a.present?).to eq true
      expect(ActionMailer::Base.deliveries.length).to eq(1)
      visit available_kids_path
      expect(page).to have_content('Lehrperson angeschrieben')
    end

    scenario 'can see accepted mentor matching' do
      visit mentor_matchings_path(mentor_matching)
    end
  end
end


feature 'MentorMatchings As Admin', js: true do
  let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher)) }
  let(:admin) { create(:admin) }
  let(:mentor) { create(:mentor) }
  let!(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid) }

  describe 'mentor matchings list' do
    before do
      log_in(admin)
      visit mentor_matchings_path
    end

    scenario 'can see mentor matchings' do
      expect(page).to have_content(mentor.display_name)
      expect(page).to have_content(kid.display_name)
      expect(page).to have_content(mentor_matching.human_state_name)
    end
  end
end

feature 'MentorMatchings As Teacher', js: true do
  let(:teacher) { create(:teacher) }
  let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher)) }
  let(:own_kid) { create(:kid, name: 'Hindler Bolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: teacher) }
  let(:mentor) { create(:mentor) }
  let(:own_mentor) { create(:mentor) }
  let!(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid) }
  let!(:own_mentor_matching) { create(:mentor_matching, mentor: own_mentor, kid: own_kid) }

  describe 'mentor matchings list' do
    before do
      log_in(teacher)
      visit mentor_matchings_path
    end

    scenario 'can see my mentor matchings' do
      expect(page).to have_content(own_mentor.display_name)
      expect(page).to have_content(own_kid.display_name)
      expect(page).to have_content(own_mentor_matching.human_state_name)
    end

    scenario 'cannot see other mentor matchings' do
      expect(page).not_to have_content(mentor.display_name)
      expect(page).not_to have_content(kid.display_name)
      expect(page).to have_content(mentor_matching.human_state_name)
    end

    scenario 'can accept mentor matching' do
      click_link('Detail')
      expect(page).to have_content('Akzeptieren')
      expect(page).to have_content(own_kid.display_name)
      expect(page).to have_content(own_mentor.display_name)

      expect { click_link('Akzeptieren') }.to change { change { ActionMailer::Base.deliveries.count }.by(1) }
      expect(own_mentor_matching.reload.state).to eq 'reserved'
    end

    scenario 'can decline mentor matching' do
      click_link('Detail')
      expect(page).to have_content('Ablehnen')
      expect(page).to have_content(own_kid.display_name)
      expect(page).to have_content(own_mentor.display_name)

      expect { click_link('Ablehnen') }.to change { change { ActionMailer::Base.deliveries.count }.by(1) }
      expect(own_mentor_matching.reload.state).to eq 'declined'
    end
  end
end