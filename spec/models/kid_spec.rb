require 'spec_helper'

describe Kid do

  context 'embedded journals' do
    let(:kid) { Factory(:kid) }
    let(:mentor) { Factory(:mentor) }
    it 'can associate a journal' do
      attrs = Factory.attributes_for(:journal, :mentor => mentor, :kid => nil)
      attrs.delete(:kid)
      kid.journals.create!(attrs)
      Kid.find(kid._id).journals.size.should eq(1)
    end
    it 'can populate journal via nested attributes' do
      kid.update_attributes(:journals_attributes =>
                            [{ 'mentor_id' => mentor.id }] )
      kid.journals.size.should eq(1)
    end
    it 'does sort journal correctly' do
      old_record =      Factory(:journal, :held_at => Date.parse('2010-01-01'), :kid => kid)
      recent_record =   Factory(:journal, :held_at => Date.parse('2020-01-01'), :kid => kid)
      very_old_record = Factory(:journal, :held_at => Date.parse('2000-01-01'), :kid => kid)
      kid.journals(true).map(&:held_at).should eq(
        [recent_record, old_record, very_old_record].map(&:held_at))
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
    it 'does associate a secondary mentor' do
      kid.secondary_mentor_id = Factory(:mentor).id
      kid.save! && kid.reload
      kid.secondary_mentor.should be_present
    end
    it 'can associate both mentors' do
      kid.mentor = Factory(:mentor)
      kid.secondary_mentor = Factory(:mentor)
      kid.save! && kid.reload
      kid.mentor.should be_present
      kid.secondary_mentor.should be_present
      kid.mentor.should_not eql(kid.secondary_mentor)
    end
    it 'can be called via secondary_kid accessor'  do
      kid.secondary_mentor = mentor = Factory(:mentor)
      kid.save! && kid.reload && mentor.reload
      mentor.secondary_kids.first.should eq(kid)
    end
  end

end
