require 'requests/acceptance_helper'

feature 'MentorMatchings As Mentor' do

  before do
    Site.load.update!(kids_schedule_hourly: false, public_signups_active: true)
    create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher))
    create(:kid, name: 'Maria Rolf', sex: 'f', longitude: 14.1025379, latitude: 50.1478497, grade: '5', teacher: create(:teacher))
    create(:kid, name: 'Olivia Rolf', sex: 'f', longitude: 14.0474263, latitude: 50.1873213, grade: '5', teacher: create(:teacher))
  end

  describe 'mentor matching' do
    let(:mentor) { create(:mentor, sex: 'm', terms_of_use_accepted: true) }
    let(:other_mentor) { create(:mentor, sex: 'm', terms_of_use_accepted: true) }
    let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', teacher: create(:teacher)) }
    let(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'reserved') }
    let(:other_mentor_matching) { create(:mentor_matching, mentor: other_mentor, kid: kid, state: 'pending') }
    before do
      log_in(mentor)
      visit available_kids_path
    end

    scenario 'can create matching' do
      click_link('Mentoringanfrage senden')
      fill_in 'Nachricht', with: 'I want to mentor the kid'
      expect {
        click_button('Mentoringanfrage absenden')
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(mentor.mentor_matchings.to_a.present?).to eq true
      visit available_kids_path
      expect(page).to have_content('Lehrperson angeschrieben')
    end

    scenario 'can see reserved mentor matching' do
      visit mentor_matchings_path(mentor_matching)
    end

    scenario 'can confirm mentor matching' do
      visit mentor_matching_path(mentor_matching)
      expect(other_mentor_matching.reload.state).to eq 'pending'

      # one email is to teacher with confirmation info
      # other email is to other_mentor with declined
      # last email is sent to admins
      expect { click_link('Bestätigen') }.to change { change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(3) }
      expect(mentor_matching.reload.state).to eq 'confirmed'
      expect(kid.reload.mentor).to eq mentor_matching.mentor
      expect(other_mentor_matching.reload.state).to eq 'declined'
    end

    scenario 'can decline mentor matching' do
      visit mentor_matching_path(mentor_matching)
      expect { click_link('Ablehnen') }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(mentor_matching.reload.state).to eq 'declined'
      expect(kid.reload.mentor).to eq nil
      expect(other_mentor_matching.reload.state).to eq 'pending'
    end
  end
end


feature 'MentorMatchings As Admin' do
  let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher)) }
  let(:admin) { create(:admin, terms_of_use_accepted: true) }
  let(:mentor) { create(:mentor, terms_of_use_accepted: true) }
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

feature 'MentorMatchings As Teacher' do
  let(:teacher) { create(:teacher, terms_of_use_accepted: true) }
  let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: create(:teacher)) }
  let(:own_kid) { create(:kid, name: 'Hindler Bolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1', teacher: teacher) }
  let(:mentor) { create(:mentor, terms_of_use_accepted: true) }
  let(:own_mentor) { create(:mentor, terms_of_use_accepted: true) }
  let!(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid) }
  let!(:own_mentor_matching) { create(:mentor_matching, mentor: own_mentor, kid: own_kid) }

  describe 'mentor matchings list' do
    before do
      Site.load.update!(kids_schedule_hourly: false, public_signups_active: true)
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

      expect { click_link('Akzeptieren') }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(own_mentor_matching.reload.state).to eq 'reserved'
    end

    scenario 'can decline mentor matching' do
      click_link('Detail')
      expect(page).to have_content('Ablehnen')
      expect(page).to have_content(own_kid.display_name)
      expect(page).to have_content(own_mentor.display_name)

      expect { click_link('Ablehnen') }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(own_mentor_matching.reload.state).to eq 'declined'
    end
  end
end