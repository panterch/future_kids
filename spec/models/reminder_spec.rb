require 'spec_helper'

describe Reminder do

  before(:each) do
    @mentor = Factory(:mentor)
    @kid = Factory(:kid, :mentor => @mentor,
                         :meeting_day => 1,
                         :meeting_start_at => Time.parse('13:30'))
  end

  let(:monday) { Time.parse('01/03/2011 22:00') }
  let(:tuesday) { Time.parse('01/04/2011 22:00') }
  let(:wednesday) { Time.parse('01/05/2011 22:00') }

  it 'creates a reminder by factory method' do
    r = Reminder.create_for(@kid, tuesday)
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

  it 'avoids reminder by batch method when already reminded' do
    Reminder.conditionally_create_reminders(tuesday)
    Reminder.conditionally_create_reminders(tuesday)
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

end
