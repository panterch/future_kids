require 'spec_helper'

describe Reminder do
  after(:each) { ActionMailer::Base.deliveries.clear }

  context 'creation' do
    before(:each) do
      @mentor = create(:mentor)
      @kid = create(:kid, mentor: @mentor,
                          meeting_day: 1,
                          meeting_start_at: Time.parse('13:30'))
    end

    let(:monday) { Time.parse('2011-01-03 22:00') }
    let(:tuesday) { Time.parse('2011-01-04 22:00') }
    let(:wednesday) { Time.parse('2011-01-05 22:00') }
    let(:next_week) { Time.parse('2011-01-09 22:00') }

    it 'creates a reminder by factory method' do
      r = Reminder.create_for(@kid, tuesday)
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
      r = Reminder.create_for(@kid, tuesday)
      expect(r.recipient).to eq(@kid.mentor.email)
    end

    it 'uses secondary mentor as recepient even when active' do
      secondary = @kid.secondary_mentor = create(:mentor)
      @kid.secondary_active = true
      r = Reminder.create_for(@kid, tuesday)
      expect(r.recipient).to eq(secondary.email)
    end

    it 'creates a reminder by batch method when criterias met' do
      Reminder.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method to early' do
      Reminder.conditionally_create_reminders(monday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'avoids reminder by batch method when already reminded same week' do
      Reminder.conditionally_create_reminders(tuesday)
      Reminder.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method when already reminded next week' do
      Reminder.conditionally_create_reminders(next_week)
      Reminder.conditionally_create_reminders(next_week)
      expect(@mentor.reminders.count).to eq(1)
    end

    it 'avoids reminder by batch method when journal entry present' do
      create(:journal, kid: @kid, mentor: @mentor,
                       held_at: monday)
      Reminder.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'avoids reminder by batch method when journal entry present in same week' do
      create(:journal, kid: @kid, mentor: @mentor,
                       held_at: wednesday)
      Reminder.conditionally_create_reminders(tuesday)
      expect(@mentor.reminders.count).to eq(0)
    end

    it 'does not send admin mail when no reminders created' do
      Kid.destroy_all
      Reminder.conditionally_create_reminders(tuesday)
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'does not send admin mail when reminder are created' do
      Reminder.conditionally_create_reminders(tuesday)
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
  end

  it 'delivers reminders' do
    @reminder = create(:reminder)
    @reminder.deliver_mail
    expect(@reminder.sent_at).not_to be_nil
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  context 'reminder scopes' do
    it 'finds active reminders' do
      reminder = create(:reminder)
      expect(Reminder.active).to eq([reminder])
    end

    it 'finds ignores acknologed reminders' do
      reminder = create(:reminder, acknowledged_at: Time.now)
      expect(Reminder.active).to be_empty
    end
  end
end
