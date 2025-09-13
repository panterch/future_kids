require 'spec_helper'

describe Principal do
  it 'has a valid factory' do
    principal = build(:principal)
    expect(principal).to be_valid
    principal.save!
  end

  it 'can have many schools' do
    principal = create(:principal)
    old_school = principal.schools.first
    new_school = create(:school)
    principal.schools << new_school
    expect(principal.schools.count).to eq(2)
    expect(principal.schools).to include(new_school, old_school)
  end
end
