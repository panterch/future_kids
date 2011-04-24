require 'spec_helper'

describe Mentor do
  it 'has a valid factory' do
    mentor = Factory.build(:mentor)
    mentor.should be_valid
  end
end
