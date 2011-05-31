require 'spec_helper'

describe Kid do

  context 'embedded journals' do
    let(:kid) { Factory(:kid) }
    it 'can associate a journal' do
      kid.journals.create(:goal => 'foo')
      Kid.find(kid._id).journals.size.should eq(1)
    end
    it 'can populate journal via nested attributes' do
      kid.update_attributes(:journals_attributes =>
                            [{ 'subject' => 'subject 1' }] )
      kid.journals.size.should eq(1)
    end
    it 'prepares a new journal entry' do
      kid.prepare_new_journal_entry
      kid.journals.size.should eq(1)
    end
    it 'does not persist empty journal entries' do
      kid.update_attributes(:journals_attributes => [{}])
      kid.journals.size.should eq(0)
    end
    it 'does sort journal correctly' do
      old_record = kid.journals.create!(:held_at => Date.parse('2010-01-01'))
      recent_record = kid.journals.create!(:held_at => Date.parse('2020-01-01'))
      new_record = kid.journals.build(:held_at => Date.parse('2011-01-01'))
      very_old_record = kid.journals.create!(:held_at => Date.parse('2000-01-01'))
      kid.journals_sorted.map(&:held_at).should eq(
        [new_record, recent_record, old_record, very_old_record].map(&:held_at))
    end
  end

  context 'relation to mentor' do
    let(:kid) { Factory.build(:kid) }
    it 'does associate a mentor' do
      kid.mentor = Factory(:mentor)
      kid.save! && kid.reload
      kid.mentor.should be_present
    end
    it 'sets mentor via mentor_id' do
      kid.mentor_id = Factory(:mentor).id
      kid.save! && kid.reload
      kid.mentor.should be_present
    end
  end

end
