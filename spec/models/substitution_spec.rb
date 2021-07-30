require 'spec_helper'

describe Substitution do
  it "has a valid factory" do
    substitution = build(:substitution)
    expect(substitution).to be_valid
    substitution.save!
  end
  it "is invalid without a start_at date" do
  	substitution = build(:substitution, start_at: nil)
  	expect(substitution).not_to be_valid
    # error on field
	end
  it "is invalid without a end_at date" do
  	substitution = build(:substitution, end_at: nil)
  	expect(substitution).not_to be_valid
	end
  it { should belong_to(:mentor).required }
  it { should belong_to(:secondary_mentor).optional  }
  it { should belong_to(:kid).required }

  it "is destroyed when kid is destroyed" do
    substitution = create(:substitution)
    substitution.kid.destroy
    expect(Substitution.exists?(substitution.id)).to be_falsey
  end

end
