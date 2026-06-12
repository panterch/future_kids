# frozen_string_literal: true

require 'spec_helper'

describe School do
  it 'has a valid factory' do
    school = build(:school)
    expect(school).to be_valid
    school.save!
  end

  context 'association with kids and mentors' do
    it 'is connected to kid' do
      school = create(:school)
      kid = create(:kid, school: school)
      expect(Kid.find(kid.id).school).to eq(school)
    end

    it { is_expected.to have_many(:kids) }

    it { is_expected.to have_many(:mentors).through(:kids) }

    it 'returns one\'s mentors' do
      @school  = create(:school)
      @mentor1 = create(:mentor)
      @mentor2 = create(:mentor)
      @kid1 = create(:kid, mentor: @mentor1, school: @school)
      @kid2 = create(:kid, mentor: @mentor2, school: @school)
      expect(@kid1.school_id).to eq(@school.id)
      expect(@kid2.school_id).to eq(@school.id)
      expect(@school.kids).to include(@kid1)
      expect(@school.kids).to include(@kid2)
      expect(@school.mentors.count).to eq(2)
      expect(@school.mentors).to include(@mentor1)
      expect(@school.mentors).to include(@mentor2)
      expect(@kid1.mentor_id).to eq(@mentor1.id)
      expect(@kid2.mentor_id).to eq(@mentor2.id)
      expect(@mentor1.kids).to include(@kid1)
      expect(@mentor2.kids).to include(@kid2)
      expect(@mentor1.schools).to include(@school)
    end
  end

  context 'active scope' do
    it 'excludes inactive schools' do
      create(:school, inactive: true)
      expect(described_class.active.count).to eq(0)
    end

    it 'includes active schools' do
      school = create(:school)
      expect(described_class.active).to include(school)
    end
  end

  context 'inactivation' do
    let(:school) { create(:school) }

    it 'stamps inactive_at when inactivated' do
      school.update!(inactive: true)
      expect(school.inactive_at).to be_present
    end

    it 'clears inactive_at when reactivated' do
      school.update!(inactive: true)
      school.update!(inactive: false)
      expect(school.inactive_at).to be_nil
    end

    it 'blocks inactivation when active kids are present' do
      create(:kid, school: school)
      school.inactive = true
      expect(school).not_to be_valid
      expect(school.errors[:inactive]).to be_present
    end

    it 'blocks inactivation when active teachers are present' do
      create(:teacher, school: school)
      school.inactive = true
      expect(school).not_to be_valid
      expect(school.errors[:inactive]).to be_present
    end

    it 'allows inactivation when no active dependents exist' do
      school.inactive = true
      expect(school).to be_valid
    end
  end

  context 'filtered by kind' do
    before do
      # Create 2 high schools, 3 gymnasiums and 1 primary school
      create(:school, school_kind: :high_school)
      create(:school, school_kind: :high_school)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :primary_school)
    end

    it 'is only of high schools or gymnasiums for mentors' do
      expect(described_class.by_kind(:mentor).length).to eq(5)
    end

    it 'is only of primary schools for kids' do
      expect(described_class.by_kind(:kid).length).to eq(1)
    end

    it 'is only of primary schools for teachers' do
      expect(described_class.by_kind(:teacher).length).to eq(1)
    end
  end
end
