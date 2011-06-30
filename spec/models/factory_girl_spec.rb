require 'spec_helper'

describe "FactoryGirl" do

  describe "a mentor by factory" do
    let(:mentor) { Factory.build(:mentor) }
    it("should be valid") { mentor.should be_valid }
    it("should be a mentor") { mentor.class.should eq(Mentor) }
  end

  describe "a admin by factory" do
    let(:admin) { Factory.build(:admin) }
    it("should be valid") { admin.should be_valid }
    it("should be a admin") { admin.class.should eq(Admin) }
  end

  describe "a kid by factory" do
    let(:kid) { Factory.build(:kid) }
    it("should be valid") { kid.should be_valid }
  end

  describe "a journal by factory" do
    let(:journal) { Factory.build(:journal) }
    it("should be valid") { journal.should be_valid }
  end

  describe "a review by factory" do
    let(:review) { Factory.build(:review) }
    it("should be valid") { review.should be_valid }
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
