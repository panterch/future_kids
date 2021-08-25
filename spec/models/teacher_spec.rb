require 'spec_helper'

describe Teacher do

  it 'has a valid factory' do
    teacher = build(:teacher)
    expect(teacher).to be_valid
  end

  describe 'journals delivery' do
    let(:teacher) { create(:teacher, receive_journals: true) }
    let(:kid) { create(:kid, teacher: teacher) }
    let(:secondary_kid) { create(:kid, secondary_teacher: teacher) }

    it 'finds todays journals' do
      journals = [create(:journal, kid: kid),
                  create(:journal, kid: secondary_kid)]
      expect(teacher.todays_journals.sort).to eq(journals.sort)
    end

    it 'ignores foreign journals' do
      create(:journal)
      expect(teacher.todays_journals.sort).to eq([])
    end

    it 'ignores older journals' do
      create(:journal, kid: kid, created_at: Date.parse('2000-01-01'))
      expect(teacher.todays_journals.sort).to eq([])
    end

    it 'delivers journals email when journals available' do
      create(:journal, kid: kid)
      create(:journal, kid: secondary_kid)
      expect {
        Teacher.conditionally_send_journals
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'does not deliver journals when no available' do
      expect {
        Teacher.conditionally_send_journals
      }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'does not deliver journals when opted out' do
      create(:journal, kid: kid)
      teacher.update(receive_journals: false)
      create(:journal)
      expect {
        Teacher.conditionally_send_journals
      }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
