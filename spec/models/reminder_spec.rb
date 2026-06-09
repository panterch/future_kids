# frozen_string_literal: true

require 'spec_helper'

describe Reminder do
  context 'creation' do
    before do
      @mentor = create(:mentor)
      @kid = create(:kid, mentor: @mentor,
                          meeting_day: 1,
                          meeting_start_at: Time.zone.parse('13:30'))
    end

    let(:monday) { Time.zone.parse('2011-01-03 22:00') }
    let(:tuesday) { Time.zone.parse('2011-01-04 22:00') }
    let(:wednesday) { Time.zone.parse('2011-01-05 22:00') }
    let(:next_week) { Time.zone.parse('2011-01-09 22:00') }

    it 'creates a reminder by factory method' do
      r = described_class.create_for(@kid, tuesday)
      expect(r.recipient).not_to be_nil
      expect(r.held_at).to eq(Date.parse('2011-01-03'))
      expect(r.week).to eq(1)
      expect(r.year).to eq(2011)
      expect(r.kid).to eq(@kid)
      expect(r.mentor).to eq(@mentor)
      expect(r.secondary_mentor).to be_nil
      expect(r.sent_at).to be_nil
    end

    it 'uses first mentor as recepient even when secondary mentor set' do
      @kid.secondary_mentor = create(:mentor)
      r = described_class.create_for(@kid, tuesday)
      expect(r.recipient).to eq(@kid.mentor.email)
    end

    it 'uses secondary mentor as recepient even when active' do
      secondary = @kid.secondary_mentor = create(:mentor)
      @kid.secondary_active = true
      r = described_class.create_for(@kid, tuesday)
      expect(r.recipient).to eq(secondary.email)
    end

    it 'creates a reminder by batch method when criterias met' do
      described_class.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method to early' do
      described_class.conditionally_create_reminders(monday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'avoids reminder by batch method when already reminded same week' do
      described_class.conditionally_create_reminders(tuesday)
      described_class.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method when already reminded next week' do
      described_class.conditionally_create_reminders(next_week)
      described_class.conditionally_create_reminders(next_week)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method when journal entry present' do
      create(:journal, kid: @kid, mentor: @mentor,
                       held_at: monday)
      described_class.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'avoids reminder by batch method when journal entry present in same week' do
      create(:journal, kid: @kid, mentor: @mentor,
                       held_at: wednesday)
      described_class.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'does not send admin mail when no reminders created' do
      Kid.destroy_all
      described_class.conditionally_create_reminders(tuesday)
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'does not send admin mail when reminder are created' do
      described_class.conditionally_create_reminders(tuesday)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  it 'delivers reminders' do
    @reminder = create(:reminder)
    expect do
      @reminder.deliver_mail
    end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    expect(@reminder.sent_at).not_to be_nil
  end

  context 'reminder scopes' do
    it 'finds active reminders' do
      reminder = create(:reminder)
      expect(described_class.active).to eq([reminder])
    end

    it 'finds ignores acknologed reminders' do
      create(:reminder, acknowledged_at: Time.zone.now)
      expect(described_class.active).to be_empty
    end
  end
end
