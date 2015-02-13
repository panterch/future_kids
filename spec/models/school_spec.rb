require 'spec_helper'

describe School do
  it 'has a valid factory' do
    school = build(:school)
    expect(school).to be_valid
    school.save!
  end

  it 'is connected to kid' do
    school = create(:school)
    kid = create(:kid, :school => school)
    expect(Kid.find(kid.id).school).to eq(school)
  end
end
