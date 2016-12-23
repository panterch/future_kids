require 'spec_helper'

describe Mentor do
  it 'has a valid factory' do
    mentor = build(:mentor)
    expect(mentor).to be_valid
  end

  context 'validations' do
    let(:mentor) { create(:mentor) }
    it 'does not require password again' do
      expect(mentor).to be_valid
    end
    it 'does ignore password overwrite with nil' do
      mentor.password = mentor.password_confirmation = nil
      expect(mentor).to be_valid
    end
    # devise triggers an error when empty passwords are entered. but this
    # is the default when submitting a form
    it 'does trigger an error on blank password' do
      mentor.password = mentor.password_confirmation = ''
      expect(mentor).to be_valid
    end
    it 'does not allow nil password on unsaved mentor' do
      new_mentor = build(:mentor)
      new_mentor.password = new_mentor.password_confirmation = nil
      expect(new_mentor).not_to be_valid
    end
  end

  context 'schedules association' do
    it 'should create associated schedules' do
      @mentor = create(:mentor)
      @mentor.update_attributes(schedules_attributes: [
        { day: 1, hour: 15, minute: 0 },
        { day: 2, hour: 16, minute: 30 }
      ])
      expect(@mentor.reload.schedules.count).to eq(2)
    end
  end

  context 'mentors grouped by assigned kids' do
    it 'does correctly group' do
      @both = create(:mentor)
      create(:kid, mentor: @both)
      create(:kid, secondary_mentor: @both)
      @only_primary = create(:mentor)
      create(:kid, mentor: @only_primary)
      @only_secondary = create(:mentor)
      create(:kid, secondary_mentor: @only_secondary)
      @substitute = create(:mentor, substitute: true)
      @none = create(:mentor)

      res = Mentor.mentors_grouped_by_assigned_kids
      expect(res[:both]).to eq [@both]
      expect(res[:only_primary]).to eq [@only_primary]
      expect(res[:only_secondary]).to eq [@only_secondary]
      expect(res[:substitute]).to eq [@substitute]
      expect(res[:none]).to eq [@none]
    end
  end

  context 'inactive setting' do
    it 'should release kids when set inactive' do
      @mentor = create(:mentor)
      create(:kid, mentor: @mentor)
      create(:kid, secondary_mentor: @mentor)
      @mentor.reload.update_attributes(inactive: true)
      expect(@mentor.reload.kids.count).to eq(0)
      expect(@mentor.secondary_kids.count).to eq(0)
    end
  end

  context 'total minutes' do
    it 'should count journals' do
      @mentor = create(:mentor)
      @journal = create(:journal, mentor: @mentor,
                                  start_at: Time.parse('13:00'),
                                  end_at: Time.parse('14:30'))
      expect(@mentor.total_duration).to eq(90)
    end
  end

  context 'month_count' do
    it 'counts journals per month' do
      @mentor = create(:mentor)
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2011-05-30'))
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2011-06-01'))
      expect(@mentor.month_count).to eq(2)
    end

    it 'counts two journals in month once' do
      @mentor = create(:mentor)
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2011-05-30'))
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2011-05-01'))
      expect(@mentor.month_count).to eq(1)
    end

    it 'counts two journals same month but different year' do
      @mentor = create(:mentor)
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2012-05-30'))
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2011-05-01'))
      expect(@mentor.month_count).to eq(2)
    end
  end

  context 'has attached file photo' do
    before do
      @file = File.new(Rails.root.join('spec/fixtures/logo.png'))
      @mentor = build(:mentor)
    end
    it 'attaches a photo' do
      @mentor.photo = @file
      @mentor.save!; @mentor = Mentor.first
      expect(@mentor.photo).to be_present
      expect(@mentor.photo.url(:thumb)).to match(/logo\.png/)
    endg
  end

  context 'association with kids and admins' do
    before do
      @admin1  = create(:admin)
      @admin2  = create(:admin)
      @mentor1 = create(:mentor)
      @mentor2 = create(:mentor)
      @kid1    = create(:kid, mentor: @mentor1, admin: @admin1)
      @kid2    = create(:kid, mentor: @mentor2, admin: @admin1)
      @kid3    = create(:kid, mentor: @mentor1, admin: @admin1)
      @kid4    = create(:kid, mentor: @mentor2, admin: @admin1)
      @kid5    = create(:kid, mentor: @mentor1, admin: @admin2)
    end

    it 'has many kids' do
      should have_many(:kids)
    end

    it 'has many admins through kids' do
      should have_many(:admins).through(:kids)
    end

    it 'should filter mentors by admins' do
      expect(@mentor1.kids.size).to eq(3)
      expect(@mentor2.kids.size).to eq(2)
      @mentors_by_admin1 = Mentor.joins(:admins).where('kids.admin_id = ?', @admin1.id).uniq
      expect(@mentors_by_admin1.size).to eq(2)
      expect(@mentors_by_admin1).to include(@mentor1)
      expect(@mentors_by_admin1).to include(@mentor2)
      @mentors_by_admin2 = Mentor.joins(:admins).where('kids.admin_id = ?', @admin2.id).uniq
      expect(@mentors_by_admin2.size).to eq(1)
      expect(@mentors_by_admin2).to include(@mentor1)
      expect(@mentors_by_admin2).to_not include(@mentor2)
    end
  end
end