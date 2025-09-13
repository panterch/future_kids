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

    it 'has many kids' do
      is_expected.to have_many(:kids)
    end

    it 'has many mentors through kids' do
      is_expected.to have_many(:mentors).through(:kids)
    end

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

  context 'filtered by kind' do
    before do
      # Create 2 high schools, 3 gymnasiums, 1 secondary school and 1 primary school
      create(:school, school_kind: :high_school)
      create(:school, school_kind: :high_school)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :gymnasium)
      create(:school, school_kind: :secondary_school)
      create(:school, school_kind: :primary_school)
    end

    it 'is only of high schools or gymnasiums for mentors' do
      expect(School.by_kind(:mentor).length).to eq(5)
    end

    it 'is only of primary and secondary schools for kids' do
      expect(School.by_kind(:kid).length).to eq(2)
    end

    it 'is only of primary and secondary schools for teachers' do
      expect(School.by_kind(:teacher).length).to eq(2)
    end
  end
end
