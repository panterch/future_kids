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
      Kid.find(kid.id).journals.size.should eq(1)
    end
    it 'can populate journal via nested attributes' do
      kid.update_attributes(:journals_attributes =>
                            [{ 'mentor_id' => mentor.id }] )
      kid.journals.size.should eq(1)
    end
    it 'does sort journal correctly' do
      old_record =      create(:journal, :held_at => Date.parse('2010-01-01'), :kid => kid)
      recent_record =   create(:journal, :held_at => Date.parse('2020-01-01'), :kid => kid)
      very_old_record = create(:journal, :held_at => Date.parse('2000-01-01'), :kid => kid)
      kid.journals(true).map(&:held_at).should eq(
        [recent_record, old_record, very_old_record].map(&:held_at))
    end
  end

  context 'relation to mentor' do
    let(:kid) { build(:kid) }
    it 'does associate a mentor' do
      kid.mentor = create(:mentor)
      kid.save! && kid.reload
      kid.mentor.should be_present
    end
    it 'sets mentor via mentor_id' do
      kid.mentor_id = create(:mentor).id
      kid.save! && kid.reload
      kid.mentor.should be_present
    end
    it 'does associate a secondary mentor' do
      kid.secondary_mentor_id = create(:mentor).id
      kid.save! && kid.reload
      kid.secondary_mentor.should be_present
    end
    it 'can associate both mentors' do
      kid.mentor = create(:mentor)
      kid.secondary_mentor = create(:mentor)
      kid.save! && kid.reload
      kid.mentor.should be_present
      kid.secondary_mentor.should be_present
      kid.mentor.should_not eql(kid.secondary_mentor)
    end
    it 'can be called via secondary_kid accessor'  do
      kid.secondary_mentor = mentor = create(:mentor)
      kid.save! && kid.reload && mentor.reload
      mentor.secondary_kids.first.should eq(kid)
    end
    it 'does sync its school with the mentors primary_kid_school field' do
      kid.school = create(:school)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      assert_equal kid.school_id, mentor.reload.primary_kids_school_id
      assert_equal kid.school.name, mentor.reload.primary_kids_school.name
      kid.mentor = nil
      kid.save!
      assert_nil mentor.reload.primary_kids_school
    end
    it 'does nilify mentors when set inactive' do
      mentor = kid.mentor = create(:mentor)
      secondary_mentor = kid.secondary_mentor = create(:mentor)
      kid.inactive = true
      kid.save!
      kid.mentor.should be_nil
      kid.secondary_mentor.should be_nil
      kid.relation_archive.should match(mentor.display_name)
      kid.relation_archive.should match(secondary_mentor.display_name)
    end
  end

  context 'relation to admin' do
    let(:kid) { build(:kid) }
    it 'does associate a mentor' do
      admin = kid.admin = create(:admin)
      kid.save! && kid.reload
      kid.admin.should be_present
      kid.admin.should eq(admin)
    end
  end

  context 'meeting time calculation' do
    before(:each) do
      @kid = create(:kid, :meeting_day => 3,
                     :meeting_start_at => Time.parse('18:00'))
    end
    it 'should return nil when not enough information' do
      @kid.meeting_day = nil
      @kid.calculate_meeting_time.should be_nil
    end
    it 'should calculate the correct meeting time in past' do
      meeting = @kid.calculate_meeting_time(thursday)
      meeting.should eq(Time.parse('2011-01-05 18:00'))
    end
    it 'should calculate the correct meeting time in future' do
      meeting = @kid.calculate_meeting_time(monday)
      meeting.should eq(Time.parse('2011-01-05 18:00'))
    end
    it 'has no journal entry due at monday' do
      @kid.journal_entry_due?(monday).should be_false
    end
    it 'has journal entry due at friday' do
      @kid.journal_entry_due?(friday).should be_true
    end
  end

  context 'journal entry for week' do
    before(:each) do
      @kid = create(:kid, :meeting_day => 2, :meeting_start_at => '13:00')
      @journal = create(:journal, :kid => @kid, :held_at => thursday)
    end
    it 'finds journal entry in future' do
      @kid.journal_entry_for_week(monday).should eq(@journal)
    end
    it 'finds journal entry in past' do
      @kid.journal_entry_for_week(friday).should eq(@journal)
    end
    it 'detects missing journal entries' do
      @journal.destroy
      @kid.journal_entry_for_week(friday).should be_nil
    end
  end

end
