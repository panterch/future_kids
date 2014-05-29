require 'spec_helper'

describe "FactoryGirl" do

  describe "a mentor by factory" do
    let(:mentor) { build(:mentor) }
    it("should be valid") { mentor.should be_valid }
    it("should be a mentor") { mentor.class.should eq(Mentor) }
  end

  describe "a admin by factory" do
    let(:admin) { build(:admin) }
    it("should be valid") { admin.should be_valid }
    it("should be a admin") { admin.class.should eq(Admin) }
  end

  describe "a kid by factory" do
    let(:kid) { build(:kid) }
    it("should be valid") { kid.should be_valid }
  end

  describe "a journal by factory" do
    let(:journal) { build(:journal) }
    it("should be valid") { journal.should be_valid }
    it("should be persistable") { journal.save!.should be_true }
  end

  describe "a cancelled journal by factory" do
    let(:journal) { build(:cancelled_journal) }
    it("should be valid") { journal.should be_valid }
    it("should be persistable") { journal.save!.should be_true }
  end

  describe "a review by factory" do
    let(:review) { build(:review) }
    it("should be valid") { review.should be_valid }
  end

  describe "a reminder by factory" do
    let(:reminder) { build(:reminder) }
    it("should be valid") { reminder.should be_valid }
    it("should be persistable") { reminder.save!.should be_true }
  end

  describe "a schedule by factory" do
    let(:schedule) { build(:schedule) }
    it("should be valid") { schedule.should be_valid }
    it("should be persistable") { schedule.save!.should be_true }
  end

  describe "a comment by factory" do
    let(:comment) { build(:comment) }
    it("should be valid") { comment.should be_valid }
    it("should be persistable") { comment.save!.should be_true }
  end

  # this test assures that the database is cleaned up before each
  # example.
  describe "a persisted mentor by factory" do
    before(:each) { create(:mentor) }
    it "should create exactly one user" do
      Mentor.count.should eq(1)
    end
    it "and cleanup the database before each test" do
      Mentor.count.should eq(1)
    end
  end

  describe "a relation log by factory" do
    let(:relation_log) { build(:relation_log) }
    it("should be valid") { relation_log.should be_valid }
    it("should be persistable") { relation_log.save!.should be_true }
  end


end
