require 'spec_helper'

describe Journal do

  it "should calculate duration" do
    j = create(:journal, :start_at => '14:00', :end_at => '14:30')
    expect(j.duration).to eq(30)
  end

  it "should calculate the year" do
    j = create(:journal, :held_at => Date.parse('2010-12-31'))
    expect(j.year).to eq(2010)
  end

  it "should calculate week end of year" do
    j = create(:journal, :held_at => Date.parse('2010-12-31'))
    expect(j.week).to eq(52)
  end

  it "should calculate week begin of year" do
    j = create(:journal, :held_at => '2010-01-01')
    expect(j.week).to eq(0)
  end

  it "creates a coaching entry at the end of the month" do
    mentor = build(:mentor)
    j = Journal.coaching_entry(mentor, '2', '2009')
    expect(j.held_at).to eq(Date.parse('2009-02-28'))
  end

end
