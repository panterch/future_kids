require 'spec_helper'

describe School do
  it 'has a valid factory' do
    school = Factory.build(:school)
    school.should be_valid
    school.save!
  end

  it 'is connected to kid' do
    school = Factory(:school)
    kid = Factory(:kid, :school => school)
    Kid.find(kid.id).school.should eq(school)
  end
end
