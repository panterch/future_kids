require 'spec_helper'

describe Schedule do
  let(:kid) { Factory(:kid) }
  let(:mentor) { Factory(:mentor) }

  it "should belong to a mentor" do
    mentor.schedules.create!(:day => 1, :hour => 13, :minute => 0)
    mentor.reload.schedules.should_not be_empty
  end

  it "should belong to a kid" do
    kid.schedules.create!(:day => 1, :hour => 13, :minute => 0)
    kid.reload.schedules.should_not be_empty
  end

  it "should does not create the same entry twice" do
    mentor.schedules.create!(:day => 1, :hour => 13, :minute => 0)
    expect { mentor.schedules.create!(:day => 1, :hour => 13, :minute => 0) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "builds schedules for a whole week" do
    week = Schedule.build_week
    week.length.should eq(5)
    week.flatten.length.should eq(5*7*2)
  end

  context "equality and enumerable methods" do
    it "is not same time when minute differs" do
      one = Factory.build(:schedule, :minute => 1)
      two = Factory.build(:schedule, :minute => 2)
      assert one != two
    end
    it "is not same time when all fields match" do
      one = Factory.build(:schedule)
      two = Factory.build(:schedule)
      assert one == two
    end
    it "includes when times matches" do
      collection = [ Factory.build(:schedule, :minute => 1),
                     Factory.build(:schedule, :minute => 2) ]
      assert collection.include?(Factory.build(:schedule, :minute => 1))
    end
    it "includes does not include when times do not match" do
      collection = [ Factory.build(:schedule, :minute => 1),
                     Factory.build(:schedule, :minute => 2) ]
      assert !collection.include?(Factory.build(:schedule, :minute => 3))
    end
    it "detect includes even on association proxy" do
      person = Factory(:schedule).person
      #                               +-- to_a is required to make include? work
      #                               v
      assert person.reload.schedules.to_a.include?(Factory.build(:schedule))
    end
  end
end
