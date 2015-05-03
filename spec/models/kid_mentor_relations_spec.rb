require 'spec_helper'

describe KidMentorRelation do

  context 'kid connected to mentor and coach' do
    let!(:kid) { create(:kid, mentor: mentor, admin: coach) }
    let!(:mentor) { create(:mentor) }
    let!(:coach) { create(:admin) }

    subject(:relation) { KidMentorRelation.first }

    it 'can lookup kid on aggregated view' do
      expect(relation).not_to be_nil
    end

    it 'associates the kid' do
      expect(relation.kid).not_to be_nil
      expect(relation.kid).to eq(kid)
    end

    it 'associates the mentor' do
      expect(relation.mentor).not_to be_nil
      expect(relation.mentor).to eq(mentor)
    end

    it 'associates the coach' do
      expect(relation.admin).not_to be_nil
      expect(relation.admin).to eq(coach)
    end

  end

  context 'kid without mentor' do
    let!(:kid) { create(:kid) }
    it 'is ignored' do
      expect(KidMentorRelation.count).to be_zero
    end
  end

  context 'inactive kid' do
    let!(:kid) { create(:kid, mentor: mentor, inactive: true) }
    let!(:mentor) { create(:mentor) }
    it 'is ignored' do
      expect(KidMentorRelation.count).to be_zero
    end
  end


end
