require 'spec_helper'

describe Admin do
  it 'has a valid factory' do
    admin = Factory.build(:admin)
    admin.should be_valid
  end
end
