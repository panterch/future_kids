require 'spec_helper'

describe Reminder do

  after(:each) { ActionMailer::Base.deliveries.clear }

  context 'creation' do

    before(:each) do
      @mentor = Factory(:mentor)
      @kid = Factory(:kid, :mentor => @mentor,
                           :meeting_day => 1,
                           :meeting_start_at => Time.parse('13:30'))
    end

    let(:monday) { Time.parse('01/03/2011 22:00') }
    let(:tuesday) { Time.parse('01/04/2011 22:00') }
    let(:wednesday) { Time.parse('01/05/2011 22:00') }
    let(:next_week) { Time.parse('01/09/2011 22:00') }

    it 'creates a reminder by factory method' do
      r = Reminder.create_for(@kid, tuesday)
      r.recipient.should_not be_nil
      r.held_at.should eq(Time.parse('01/03/2011 13:30'))
      r.week.should eq(1)
      r.year.should eq(2011)
      r.kid.should eq(@kid)
      r.mentor.should eq(@mentor)
      r.secondary_mentor.should be_nil
      r.sent_at.should be_nil
    end

    it 'creates a reminder by batch method when criterias met' do
      Reminder.conditionally_create_reminders(tuesday)
      @mentor.reminders.count.should eq(1)
    end

    it 'avoids reminder by batch method to early' do
      Reminder.conditionally_create_reminders(monday)
      @mentor.reminders.count.should eq(0)
    end

    it 'avoids reminder by batch method when already reminded same week' do
      Reminder.conditionally_create_reminders(tuesday)
      Reminder.conditionally_create_reminders(tuesday)
      @mentor.reminders.count.should eq(1)
    end

    it 'avoids reminder by batch method when already reminded next week' do
      Reminder.conditionally_create_reminders(next_week)
      Reminder.conditionally_create_reminders(next_week)
      @mentor.reminders.count.should eq(1)
    end

    it 'avoids reminder by batch method when journal entry present' do
      Factory(:journal, :kid => @kid, :mentor => @mentor,
                        :held_at => monday)
      Reminder.conditionally_create_reminders(tuesday)
      @mentor.reminders.count.should eq(0)
    end

    it 'avoids reminder by batch method when journal entry present in same week' do
      Factory(:journal, :kid => @kid, :mentor => @mentor,
                        :held_at => wednesday)
      Reminder.conditionally_create_reminders(tuesday)
      @mentor.reminders.count.should eq(0)
    end

    it 'does not send admin mail when no reminders created' do
      Kid.destroy_all
      Reminder.conditionally_create_reminders(tuesday)
      ActionMailer::Base.deliveries.should be_empty
    end

    it 'does not send admin mail when reminder are created' do
      Reminder.conditionally_create_reminders(tuesday)
      ActionMailer::Base.deliveries.should_not be_empty
    end

  end


  it 'delivers reminders' do
    @reminder = Factory(:reminder)
    @reminder.deliver_mail
    @reminder.sent_at.should_not be_nil
    ActionMailer::Base.deliveries.should_not be_empty
  end

end
