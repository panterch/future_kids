require 'spec_helper'

describe Admin do
  it 'has a valid factory' do
    admin = build(:admin)
    expect(admin).to be_valid
  end

  it 'releases coachings when set inactive' do
    admin = create(:admin)
    create(:kid, :admin_id => admin.id)
    create(:kid, :admin_id => admin.id)
    assert_equal 2, admin.coachings(true).count
    admin.inactive = true
    admin.save!
    assert_equal 0, admin.coachings(true).count
    assert_equal 0, Kid.where(:admin_id => admin.id).count
  end
end
