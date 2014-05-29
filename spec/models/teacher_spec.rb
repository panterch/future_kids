require 'spec_helper'

describe Teacher do
  it 'has a valid factory' do
    teacher = build(:teacher)
    teacher.should be_valid
  end
end
