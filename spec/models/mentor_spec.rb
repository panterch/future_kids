require 'spec_helper'

describe Mentor do
  include ActionDispatch::TestProcess::FixtureFile

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
    it 'creates associated schedules' do
      @mentor = create(:mentor)
      @mentor.update(schedules_attributes: [
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
    it 'releases kids when set inactive' do
      @mentor = create(:mentor)
      create(:kid, mentor: @mentor)
      create(:kid, secondary_mentor: @mentor)
      @mentor.reload.update(inactive: true)
      expect(@mentor.reload.kids.count).to eq(0)
      expect(@mentor.secondary_kids.count).to eq(0)
    end
  end

  context 'total minutes' do
    it 'counts journals' do
      @mentor = create(:mentor)
      @journal = create(:journal, mentor: @mentor,
                                  start_at: Time.parse('13:00'),
                                  end_at: Time.parse('14:30'))
      expect(@mentor.total_duration).to eq(90)
    end
  end

  context 'total duration' do
    before do
      @mentor = create(:mentor)
      create(:journal, mentor: @mentor,
                       held_at: Date.parse('2001-05-30'),
                       start_at: Time.parse('13:00'),
                       end_at: Time.parse('14:30'))
      create(:journal, mentor: @mentor,
                       held_at: Date.today - 1.month,
                       start_at: Time.parse('13:00'),
                       end_at: Time.parse('13:30'))
      create(:journal, mentor: @mentor,
                       held_at: Date.today - 1.month,
                       start_at: Time.parse('13:00'),
                       end_at: Time.parse('14:30'))
    end

    it 'sums up duration' do
      expect(@mentor.total_duration).to eq(210)
    end

    it 'sums up last months duration' do
      # sum of journal entries + coaching
      expect(@mentor.total_duration_last_month_with_coaching).to eq(180)
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
      @file = fixture_file_upload('logo.png')
      @mentor = build(:mentor)
    end

    it 'attaches a photo' do
      @mentor.photo.attach(@file)
      @mentor.save!
      @mentor = Mentor.first
      expect(@mentor.photo).to be_present
      expect(@mentor.photo_medium.blob.filename.to_s).to match(/logo\.png/)
    end
  end

  context 'association with kids, admins, meeting day and schools' do
    before do
      @admin1  = create(:admin)
      @admin2  = create(:admin)
      @mentor1 = create(:mentor)
      @mentor2 = create(:mentor)
      @school1 = create(:school)
      @school2 = create(:school)
      @kid1    = create(:kid, mentor: @mentor1, admin: @admin1, meeting_day: '1', school: @school1)
      @kid2    = create(:kid, mentor: @mentor2, admin: @admin1, meeting_day: '1', school: @school1)
      @kid3    = create(:kid, mentor: @mentor1, admin: @admin1, meeting_day: '1', school: @school1)
      @kid4    = create(:kid, mentor: @mentor2, admin: @admin1, meeting_day: '1', school: @school1)
      @kid5    = create(:kid, mentor: @mentor1, admin: @admin2, meeting_day: '2', school: @school2)
    end

    it 'has many kids' do
      expect(subject).to have_many(:kids)
    end

    it 'has many admins through kids' do
      expect(subject).to have_many(:admins).through(:kids)
    end

    it 'has many schools through kids' do
      expect(subject).to have_many(:schools).through(:kids)
    end

    it 'has his own school' do
      expect(subject).to belong_to(:school).optional
    end

    it 'filters mentors by admins' do
      expect(@mentor1.kids.size).to eq(3)
      expect(@mentor2.kids.size).to eq(2)
      @mentors_by_admin1 = Mentor.joins(:admins).where('kids.admin_id = ?', @admin1.id).distinct!
      expect(@mentors_by_admin1.size).to eq(2)
      expect(@mentors_by_admin1).to include(@mentor1)
      expect(@mentors_by_admin1).to include(@mentor2)
      @mentors_by_admin2 = Mentor.joins(:admins).where('kids.admin_id = ?', @admin2.id).distinct!
      expect(@mentors_by_admin2.size).to eq(1)
      expect(@mentors_by_admin2).to include(@mentor1)
      expect(@mentors_by_admin2).not_to include(@mentor2)
    end

    it 'filters mentors by meeting day' do
      @mentors_by_meeting_day1 = Mentor.joins(:kids).where('kids.meeting_day = ?', '1').distinct!
      expect(@mentors_by_meeting_day1.size).to eq(2)
      expect(@mentors_by_meeting_day1).to include(@mentor1)
      expect(@mentors_by_meeting_day1).to include(@mentor2)
      @mentors_by_meeting_day2 = Mentor.joins(:kids).where('kids.meeting_day = ?', '2').distinct!
      expect(@mentors_by_meeting_day2.size).to eq(1)
      expect(@mentors_by_meeting_day2).to include(@mentor1)
      expect(@mentors_by_meeting_day2).not_to include(@mentor2)
    end

    it 'filters mentors by schools' do
      @mentors_by_school1 = Mentor.joins(:schools).where('kids.school_id = ?', @school1.id).distinct!
      expect(@mentors_by_school1.size).to eq(2)
      expect(@mentors_by_school1.size).to eq(2)
      expect(@mentors_by_school1).to include(@mentor1)
      expect(@mentors_by_school1).to include(@mentor2)
      @mentors_by_school2 = Mentor.joins(:schools).where('kids.school_id = ?', @school2.id).distinct!
      expect(@mentors_by_school2.size).to eq(1)
      expect(@mentors_by_school2).to include(@mentor1)
      expect(@mentors_by_school2).not_to include(@mentor2)
    end
  end

  context 'geocoding' do
    let(:kid) { create(:kid) }

    it 'uses full address' do
      kid.address = 'Street 1'
      kid.city = 'City'
      expect(kid.full_address).to eq('Street 1 City')
    end

    it 'stores correct coordinates' do
      kid.address = 'Street 1'
      kid.city = 'City'
      kid.save!
      expect(kid.full_address).to eq('Street 1 City')
      expect(kid.latitude).to eq(1.111)
      expect(kid.longitude).to eq(1.234)
    end

    it 'retrieve coords based only on city' do
      kid.address = ''
      kid.city = 'City'
      kid.save!
      expect(kid.full_address).to eq('City')
      expect(kid.latitude).to eq(4.321)
      expect(kid.longitude).to eq(1.234)
    end

    it 'sets coords nil if address is not found' do
      kid.address = 'Street 404'
      kid.city = 'Notfoundtown'
      kid.save!
      expect(kid.latitude.blank?).to be_truthy
      expect(kid.longitude.blank?).to be_truthy
    end

    it 'resets coordinates if address becomes blank' do
      kid.address = ''
      kid.city = ''
      kid.save!
      expect(kid.latitude.blank?).to be_truthy
      expect(kid.longitude.blank?).to be_truthy
    end
  end
end
