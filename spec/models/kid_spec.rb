require 'spec_helper'

describe Kid do
  let(:monday) { Time.zone.parse('2011-01-03 22:00') }
  let(:thursday) { Time.zone.parse('2011-01-06 22:00') }
  let(:friday) { Time.zone.parse('2011-01-07 22:00') }

  context 'dates' do
    subject { build(:kid) }

    it { should allow_values(Date.parse('2021-11-18')).for(:dob) }
    it { should_not allow_values(Date.parse('0021-11-18')).for(:dob) }
    it { should allow_values(Date.parse('2021-11-18')).for(:exit_at) }
    it { should_not allow_values(Date.parse('0021-11-18')).for(:exit_at) }
    it { should allow_values(Date.parse('2021-11-18')).for(:checked_at) }
    it { should_not allow_values(Date.parse('0021-11-18')).for(:checked_at) }
    it { should allow_values(Date.parse('2021-11-18')).for(:coached_at) }
    it { should_not allow_values(Date.parse('0021-11-18')).for(:coached_at) }

  end

  context 'embedded journals' do
    let(:kid) { create(:kid) }
    let(:mentor) { create(:mentor) }
    it 'can associate a journal' do
      attrs = attributes_for(:journal)
      attrs[:mentor_id] = mentor.id
      kid.journals.create!(attrs)
      expect(Kid.find(kid.id).journals.size).to eq(1)
    end
    it 'can populate journal via nested attributes' do
      kid.update(journals_attributes:[{ 'mentor_id' => mentor.id }])
      expect(kid.journals.size).to eq(1)
    end
    it 'does sort journal correctly' do
      old_record =      create(:journal, held_at: Date.parse('2010-01-01'), kid: kid)
      recent_record =   create(:journal, held_at: Date.parse('2020-01-01'), kid: kid)
      very_old_record = create(:journal, held_at: Date.parse('2002-01-01'), kid: kid)
      expect(kid.journals.map(&:held_at)).to eq(
        [recent_record, old_record, very_old_record].map(&:held_at))
    end
    it 'cleans up journals on deletion' do
      journal = create(:journal, kid: kid)
      kid.destroy
      expect(Journal.exists?(journal.id)).to be_falsey
      expect(Kid.exists?(kid.id)).to be_falsey
    end
  end

  context 'relation to mentor' do
    let(:kid) { build(:kid) }
    it 'validates on factory values' do
      expect(kid).to be_valid
    end
    it 'does invalidate without goals' do
      kid.goal_1 = ""
      kid.goal_2 = ""
      expect(kid).to_not be_valid
    end
    it 'does validate by checking one goal per group' do
      kid.goal_1 = ""
      kid.goal_2 = ""
      kid.goal_3 = true
      kid.goal_35 = true
      expect(kid).to be_valid
    end
  end


      context 'relation to mentor' do
    let(:kid) { build(:kid) }
    it 'does associate a mentor' do
      kid.mentor = create(:mentor)
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
    end

    it 'sets mentor via mentor_id' do
      kid.mentor_id = create(:mentor).id
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
    end

    it 'does associate a secondary mentor' do
      kid.secondary_mentor_id = create(:mentor).id
      kid.save! && kid.reload
      expect(kid.secondary_mentor).to be_present
    end

    it 'can associate both mentors' do
      kid.mentor = create(:mentor)
      kid.secondary_mentor = create(:mentor)
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
      expect(kid.secondary_mentor).to be_present
      expect(kid.mentor).not_to eql(kid.secondary_mentor)
    end

    it 'can be called via secondary_kid accessor'  do
      kid.secondary_mentor = mentor = create(:mentor)
      kid.save! && kid.reload && mentor.reload
      expect(mentor.secondary_kids.first).to eq(kid)
    end

    it 'does sync its school with the mentors school through association' do
      kid.school = create(:school)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.school_id).to eq mentor.reload.kids.last.school_id
      expect(kid.school.display_name).to eq mentor.reload.kids.last.school.display_name
      kid.school = nil
      kid.save!
      expect(mentor.reload.kids.last.school).to be_nil
    end

    it 'does sync its coach with the mentors coach through association' do
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.admin_id).to eq mentor.reload.kids.last.admin_id
      expect(kid.admin.display_name).to eq mentor.reload.kids.last.admin.display_name
      kid.admin = nil
      kid.save!
      expect(mentor.reload.kids.last.admin).to be_nil
    end

    it 'does sync its meeting day with mentor' do
      kid = create(:kid, meeting_day: '1')
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.meeting_day).to eq(mentor.reload.kids.last.meeting_day)
      kid.meeting_day = nil
      kid.save!
      expect(mentor.reload.kids.last.meeting_day).to be_nil
    end

    it 'does release synced relations on mentors when inactivated' do
      kid.school = create(:school)
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(mentor.reload.kids.last.school).to be_truthy
      expect(mentor.reload.kids.last.admin).to be_truthy
      kid.inactive = true
      kid.save!
      expect(mentor.reload.kids).to be_empty
      expect(mentor.reload.schools.count).to eq(0)
      expect(mentor.reload.admins.count).to eq(0)
    end

    it 'does nilify mentors when set inactive' do
      kid.mentor = create(:mentor)
      kid.secondary_mentor = create(:mentor)
      kid.admin = create(:admin)
      kid.save!

      k = Kid.find(kid.id)
      k.inactive = true
      k.save!

      k = Kid.find(k.id)
      expect(k.mentor).to be_nil
      expect(k.secondary_mentor).to be_nil
      expect(k.admin).to be_nil
    end
  end

  context 'relation to admin' do
    let(:kid) { build(:kid) }
    it 'does associate a mentor' do
      admin = kid.admin = create(:admin)
      kid.save! && kid.reload
      expect(kid.admin).to be_present
      expect(kid.admin).to eq(admin)
    end
  end

  context 'specific updated_at fields' do
    let(:kid) { create(:kid) }
    let!(:time) { Time.now }

    it 'tracks schedulue updates' do
      expect(kid.schedules_updated_at).to be_nil
      kid.schedules.create!(day: 1, hour: 13, minute: 0)
      expect(kid.schedules_updated_at).to be > time
    end
  end

  context 'meeting time calculation' do
    before(:each) do
      @kid = create(:kid, meeting_day: 3,
                          meeting_start_at: Time.zone.parse('18:00'))
    end
    it 'should return saturday evening when not enough information' do
      @kid.meeting_day = nil
      meeting = @kid.calculate_meeting_time(thursday)
      expect(meeting).to eq(Time.zone.parse('2011-01-08 18:00'))
    end
    it 'should calculate the correct meeting time in past' do
      meeting = @kid.calculate_meeting_time(thursday)
      expect(meeting).to eq(Time.zone.parse('2011-01-05 18:00'))
    end
    it 'should calculate the correct meeting time in future' do
      meeting = @kid.calculate_meeting_time(monday)
      expect(meeting).to eq(Time.zone.parse('2011-01-05 18:00'))
    end
    it 'has no journal entry due at monday' do
      expect(@kid.journal_entry_due?(monday)).to be_falsey
    end
    it 'has journal entry due at friday' do
      expect(@kid.journal_entry_due?(friday)).to be_truthy
    end
  end

  context 'journal entry for week' do
    before(:each) do
      @kid = create(:kid, meeting_day: 2, meeting_start_at: '13:00')
      @journal = create(:journal, kid: @kid, held_at: thursday)
    end
    it 'finds journal entry in future' do
      expect(@kid.journal_entry_for_week(monday)).to eq(@journal)
    end
    it 'finds journal entry in past' do
      expect(@kid.journal_entry_for_week(friday)).to eq(@journal)
    end
    it 'detects missing journal entries' do
      @journal.destroy
      expect(@kid.journal_entry_for_week(friday)).to be_nil
    end
  end

  context 'association with admin, mentor and school' do
    it 'has admin' do
      should belong_to(:admin).optional
    end

    it 'has mentor' do
      should belong_to(:mentor).optional
    end

    it 'has school' do
      should belong_to(:school).optional
    end
  end

  context 'geocoding' do

    # see config/initializers/geocoder.rb

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

    it 'overwrites longitude latitude in test when explicitly set' do
      k = create(:kid, name: 'Hodler Rolf')
      k.update!(longitude: 3.14, latitude: 1.41)
      expect(k.latitude).to eq(1.41)
      expect(k.longitude).to eq(3.14)
    end
  end
end
