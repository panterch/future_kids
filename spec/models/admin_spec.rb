require 'spec_helper'

describe Admin do
  it 'has a valid factory' do
    admin = build(:admin)
    expect(admin).to be_valid
  end

  it 'releases coachings when set inactive' do
    admin = create(:admin)
    create(:kid, admin_id: admin.id)
    create(:kid, admin_id: admin.id)
    expect(admin.coachings.count).to eq 2
    admin.inactive = true
    admin.save!
    expect(admin.coachings.count). to eq 0
    expect(Kid.where(admin_id: admin.id).count).to eq 0
  end

  context 'model association' do
    it 'has many kids' do
      should have_many(:coachings)
    end

    it 'has many mentors through kids' do
      should have_many(:mentors).through(:coachings)
    end

    it 'should return one\'s mentors' do
      @admin = create(:admin)
      @mentor = create(:mentor)
      @mentor2 = create(:mentor)
      @kid1 = create(:kid, mentor: @mentor, admin: @admin)
      @kid2 = create(:kid, mentor: @mentor2, admin: @admin)
      expect(@kid1.admin_id).to eq(@admin.id)
      expect(@kid2.admin_id).to eq(@admin.id)
      expect(@admin.coachings).to include(@kid1)
      expect(@admin.coachings).to include(@kid2)
      expect(@admin.mentors.count).to eq(2)
      expect(@admin.mentors).to include(@mentor)
      expect(@admin.mentors).to include(@mentor2)
      expect(@kid1.mentor_id).to eq(@mentor.id)
      expect(@kid2.mentor_id).to eq(@mentor2.id)
      expect(@mentor.kids).to include(@kid1)
      expect(@mentor2.kids).to include(@kid2)
      expect(@mentor.admins).to include(@admin)
    end
  end
end
