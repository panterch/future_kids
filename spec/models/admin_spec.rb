require 'spec_helper'

describe Admin do
  it 'has a valid factory' do
    admin = Factory.build(:admin)
    admin.should be_valid
  end

  it 'releases coachings when set inactive' do
    admin = Factory.create(:admin)
    Factory.create(:kid, :admin_id => admin.id)
    Factory.create(:kid, :admin_id => admin.id)
    assert_equal 2, admin.coachings(true).count
    admin.inactive = true
    admin.save!
    assert_equal 0, admin.coachings(true).count
    assert_equal 0, Kid.where(:admin_id => admin.id).count
  end
end
