require 'spec_helper'

describe 'FactoryGirl' do
  describe 'a mentor by factory' do
    let(:mentor) { build(:mentor) }
    it('should be valid') { expect(mentor).to be_valid }
    it('should be a mentor') { expect(mentor.class).to eq(Mentor) }
  end

  describe 'a admin by factory' do
    let(:admin) { build(:admin) }
    it('should be valid') { expect(admin).to be_valid }
    it('should be a admin') { expect(admin.class).to eq(Admin) }
  end

  describe 'a kid by factory' do
    let(:kid) { build(:kid) }
    it('should be valid') { expect(kid).to be_valid }
  end

  describe 'a journal by factory' do
    let(:journal) { build(:journal) }
    it('should be valid') { expect(journal).to be_valid }
    it('should be persistable') { expect(journal.save!).to be_truthy }
  end

  describe 'a cancelled journal by factory' do
    let(:journal) { build(:cancelled_journal) }
    it('should be valid') { expect(journal).to be_valid }
    it('should be persistable') { expect(journal.save!).to be_truthy }
  end

  describe 'a review by factory' do
    let(:review) { build(:review) }
    it('should be valid') { expect(review).to be_valid }
  end

  describe 'a reminder by factory' do
    let(:reminder) { build(:reminder) }
    it('should be valid') { expect(reminder).to be_valid }
    it('should be persistable') { expect(reminder.save!).to be_truthy }
  end

  describe 'a schedule by factory' do
    let(:schedule) { build(:schedule) }
    it('should be valid') { expect(schedule).to be_valid }
    it('should be persistable') { expect(schedule.save!).to be_truthy }
  end

  describe 'a comment by factory' do
    let(:comment) { build(:comment) }
    it('should be valid') { expect(comment).to be_valid }
    it('should be persistable') { expect(comment.save!).to be_truthy }
  end

  # this test assures that the database is cleaned up before each
  # example.
  describe 'a persisted mentor by factory' do
    before(:each) { create(:mentor) }
    it 'should create exactly one user' do
      expect(Mentor.count).to eq(1)
    end
    it 'and cleanup the database before each test' do
      expect(Mentor.count).to eq(1)
    end
  end

  describe 'a relation log by factory' do
    let(:relation_log) { build(:relation_log) }
    it('should be valid') { expect(relation_log).to be_valid }
    it('should be persistable') { expect(relation_log.save!).to be_truthy }
  end
end
