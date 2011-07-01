require 'spec_helper'

describe Journal do

  it "should calculate duration" do
    j = Factory(:journal, :start_at => '14:00', :end_at => '14:30')
    j.duration.should eq(30)
  end

  it "should calculate the year" do
    j = Factory(:journal, :held_at => '12/31/2010')
    j.year.should eq(2010)
  end

  it "should calculate week end of year" do
    j = Factory(:journal, :held_at => '12/31/2010')
    j.week.should eq(52)
  end

  it "should calculate week begin of year" do
    j = Factory(:journal, :held_at => '01/01/2010')
    j.week.should eq(0)
  end

end
