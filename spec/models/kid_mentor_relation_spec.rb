# frozen_string_literal: true

require 'spec_helper'

describe KidMentorRelation do
  context 'kid connected to mentor and coach' do
    subject(:relation) { described_class.first }

    let!(:kid) { create(:kid, mentor: mentor, admin: coach) }
    let!(:mentor) { create(:mentor) }
    let!(:coach) { create(:admin) }

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
    before { create(:kid) }

    it 'is found' do
      expect(described_class.count).to eq(1)
    end
  end

  context 'inactive kid' do
    let!(:mentor) { create(:mentor) }

    before { create(:kid, mentor: mentor, inactive: true) }

    it 'is ignored' do
      expect(described_class.count).to be_zero
    end
  end

  describe '.reset_all' do
    let!(:mentor) do
      create(:mentor, exit_kind: 'exit', exit_at: Date.new(2026, 12, 24), exit: '2026 Herbst')
    end
    let!(:kid) do
      create(:kid, mentor: mentor, exit_kind: 'exit', exit_at: Date.new(2026, 12, 24),
                   exit: '2026 Herbst', exit_reason: 'Wegzug')
    end

    it 'clears the exit kind, exit date, exit term and (for kids) exit reason' do
      described_class.reset_all

      expect(kid.reload).to have_attributes(exit_kind: nil, exit_at: nil, exit: nil, exit_reason: nil)
      expect(mentor.reload).to have_attributes(exit_kind: nil, exit_at: nil, exit: nil)
    end
  end
end
