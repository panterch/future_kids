require 'spec_helper'

describe 'FactoryBot' do
  describe 'a mentor by factory' do
    let(:mentor) { build(:mentor) }

    it('is valid') { expect(mentor).to be_valid }
    it('is a mentor') { expect(mentor.class).to eq(Mentor) }
  end

  describe 'a admin by factory' do
    let(:admin) { build(:admin) }

    it('is valid') { expect(admin).to be_valid }
    it('is a admin') { expect(admin.class).to eq(Admin) }
  end

  describe 'a kid by factory' do
    let(:kid) { build(:kid) }

    it('is valid') { expect(kid).to be_valid }
  end

  describe 'a journal by factory' do
    let(:journal) { build(:journal) }

    it('is valid') { expect(journal).to be_valid }
    it('is persistable') { expect(journal.save!).to be_truthy }
  end

  describe 'a cancelled journal by factory' do
    let(:journal) { build(:cancelled_journal) }

    it('is valid') { expect(journal).to be_valid }
    it('is persistable') { expect(journal.save!).to be_truthy }
  end

  describe 'a review by factory' do
    let(:review) { build(:review) }

    it('is valid') { expect(review).to be_valid }
  end

  describe 'a reminder by factory' do
    let(:reminder) { build(:reminder) }

    it('is valid') { expect(reminder).to be_valid }
    it('is persistable') { expect(reminder.save!).to be_truthy }
  end

  describe 'a schedule by factory' do
    let(:schedule) { build(:schedule) }

    it('is valid') { expect(schedule).to be_valid }
    it('is persistable') { expect(schedule.save!).to be_truthy }
  end

  describe 'a comment by factory' do
    let(:comment) { build(:comment) }

    it('is valid') { expect(comment).to be_valid }
    it('is persistable') { expect(comment.save!).to be_truthy }
    it('associates a journal') { expect(comment.journal).to be_present }
  end

  # this test assures that the database is cleaned up before each
  # example.
  describe 'a persisted mentor by factory' do
    before { create(:mentor) }

    it 'creates exactly one user' do
      expect(Mentor.count).to eq(1)
    end

    it 'and cleanup the database before each test' do
      expect(Mentor.count).to eq(1)
    end
  end

  describe 'a relation log by factory' do
    let(:relation_log) { build(:relation_log) }

    it('is valid') { expect(relation_log).to be_valid }
    it('is persistable') { expect(relation_log.save!).to be_truthy }
  end

  describe 'a first_year_assessment by factory' do
    let(:first_year_assessment) { build(:first_year_assessment) }

    it('is valid') { expect(first_year_assessment).to be_valid }
    it('is persistable') { expect(first_year_assessment.save!).to be_truthy }
  end
end
