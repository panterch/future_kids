require 'spec_helper'

describe Substitution, :issue126 => true do
  it "has a valid factory" do
    substitution = build(:substitution)
    expect(substitution).to be_valid
    substitution.save!
  end
  it "is invalid without a start_at date" do
  	substitution = build(:substitution, start_at: nil)
  	expect(substitution).not_to be_valid
	end
  it "is invalid without a end_at date" do
  	substitution = build(:substitution, end_at: nil)
  	expect(substitution).not_to be_valid
	end
  it "returns a contact's full name as a string"
end
