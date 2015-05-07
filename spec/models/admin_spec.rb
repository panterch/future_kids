require 'spec_helper'

describe Admin do
  it 'has a valid factory' do
    admin = build(:admin)
    expect(admin).to be_valid
  end

  it 'releases coachings when set inactive' do
    admin = create(:admin)
    create(:kid, admin_id: admin.id)
    create(:kid, admin_id: admin.id)
    expect(admin.coachings.count).to eq 2
    admin.inactive = true
    admin.save!
    expect(admin.coachings.count). to eq 0
    expect(Kid.where(admin_id: admin.id).count).to eq 0
  end
end
