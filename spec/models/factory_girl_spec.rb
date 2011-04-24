require 'spec_helper'

describe "FactoryGirl" do

  describe "a mentor by factory" do
    let(:mentor) { Factory.build(:mentor) }
    it("should be valid") { mentor.should be_valid }
  end

  # this test assures that the database is cleaned up before each
  # example.
  describe "a persisted mentor by factory" do
    before(:each) { Factory(:mentor) }
    it "should create exactly one user" do
      Mentor.count.should eq(1)
    end
    it "and cleanup the database before each test" do
      Mentor.count.should eq(1)
    end
  end


end
