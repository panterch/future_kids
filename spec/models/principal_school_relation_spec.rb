require 'spec_helper'

RSpec.describe PrincipalSchoolRelation, type: :model do
  it 'has a valid factory' do
    principal_school_relation = build(:principal_school_relation)
    expect(principal_school_relation).to be_valid
  end
end
