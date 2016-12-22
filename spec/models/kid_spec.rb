require 'spec_helper'

describe Kid do
  let(:monday) { Time.parse('2011-01-03 22:00') }
  let(:thursday) { Time.parse('2011-01-06 22:00') }
  let(:friday) { Time.parse('2011-01-07 22:00') }

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
      kid.update_attributes(journals_attributes:[{ 'mentor_id' => mentor.id }])
      expect(kid.journals.size).to eq(1)
    end
    it 'does sort journal correctly' do
      old_record =      create(:journal, held_at: Date.parse('2010-01-01'), kid: kid)
      recent_record =   create(:journal, held_at: Date.parse('2020-01-01'), kid: kid)
      very_old_record = create(:journal, held_at: Date.parse('2000-01-01'), kid: kid)
      expect(kid.journals(true).map(&:held_at)).to eq(
        [recent_record, old_record, very_old_record].map(&:held_at))
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
    it 'does sync its school with the mentors primary_kid_school field' do
      kid.school = create(:school)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.school_id).to eq mentor.reload.primary_kids_school_id
      expect(kid.school.name).to eq mentor.reload.primary_kids_school.name
      kid.mentor = nil
      kid.save!
      expect(mentor.reload.primary_kids_school).to be_nil
    end

    it 'does sync its coach with the mentors primary_kid_coach field' do
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.admin_id). to eq mentor.reload.kids.last.admin_id
      expect(kid.admin.display_name).to eq mentor.reload.kids.last.admin.display_name
      kid.admin = nil
      kid.save!
      expect(mentor.reload.kids.last.admin).to be_nil
    end
    it 'does release synced relations on mentors when inactivated' do
      kid.school = create(:school)
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(mentor.reload.primary_kids_school).to be_truthy
      expect(mentor.reload.kids.last.admin).to be_truthy
      kid.inactive = true
      kid.save!
      expect(mentor.reload.kids).to be_empty
      expect(mentor.reload.primary_kids_school).to be_nil
      expect(mentor.reload.admins.count).to eq(0)
    end
    it 'does nilify mentors when set inactive' do
      mentor = kid.mentor = create(:mentor)
      secondary_mentor = kid.secondary_mentor = create(:mentor)
      kid.inactive = true
      kid.save!
      expect(kid.mentor).to be_nil
      expect(kid.secondary_mentor).to be_nil
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
    it 'should track changing goals' do
      kid.goal_1 = kid.goal_2 = 'goal'
      kid.save!
      expect(kid.goal_1_updated_at).to be > time
      expect(kid.goal_2_updated_at).to be > time
    end

    it 'should track changing goals independently' do
      kid.goal_1 = kid.goal_2 = 'goal'
      kid.save!
      time = Time.now
      kid.goal_2 = 'updated'
      kid.save!
      expect(kid.goal_1_updated_at).to be < time
      expect(kid.goal_2_updated_at).to be > time
    end

    it 'tracks schedulue updates' do
      expect(kid.schedules_updated_at).to be_nil
      kid.schedules.create!(day: 1, hour: 13, minute: 0)
      expect(kid.schedules_updated_at).to be > time
    end
  end

  context 'meeting time calculation' do
    before(:each) do
      @kid = create(:kid, meeting_day: 3,
                          meeting_start_at: Time.parse('18:00'))
    end
    it 'should return nil when not enough information' do
      @kid.meeting_day = nil
      expect(@kid.calculate_meeting_time).to be_nil
    end
    it 'should calculate the correct meeting time in past' do
      meeting = @kid.calculate_meeting_time(thursday)
      expect(meeting).to eq(Time.parse('2011-01-05 18:00'))
    end
    it 'should calculate the correct meeting time in future' do
      meeting = @kid.calculate_meeting_time(monday)
      expect(meeting).to eq(Time.parse('2011-01-05 18:00'))
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

  context 'model association' do
    it 'has admin' do
      should belong_to(:admin)
    end

    it 'has mentor' do
      should belong_to(:mentor)
    end
  end
end