require 'spec_helper'

describe Principal do
  it 'has a valid factory' do
    principal = build(:principal)
    expect(principal).to be_valid
    principal.save!
  end
end
