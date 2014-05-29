require 'spec_helper'

describe Journal do

  it "should calculate duration" do
    j = Factory(:journal, :start_at => '14:00', :end_at => '14:30')
    j.duration.should eq(30)
  end

  it "should calculate the year" do
    j = Factory(:journal, :held_at => Date.parse('2010-12-31'))
    j.year.should eq(2010)
  end

  it "should calculate week end of year" do
    j = Factory(:journal, :held_at => Date.parse('2010-12-31'))
    j.week.should eq(52)
  end

  it "should calculate week begin of year" do
    j = Factory(:journal, :held_at => '2010-01-01')
    j.week.should eq(0)
  end

  it "creates a coaching entry at the end of the month" do
    mentor = Factory.build(:mentor)
    j = Journal.coaching_entry(mentor, '2', '2009')
    j.held_at.should eq(Date.parse('2009-02-28'))
  end

end
