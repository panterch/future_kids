require 'spec_helper'

describe Teacher do

  after(:each) { ActionMailer::Base.deliveries.clear }

  it 'has a valid factory' do
    teacher = build(:teacher)
    teacher.should be_valid
  end

  describe 'journals delivery' do
    let(:teacher) { create(:teacher, receive_journals: true) }
    let(:kid) { create(:kid, teacher: teacher) }
    let(:secondary_kid) { create(:kid, secondary_teacher: teacher) }

    it 'finds todays journals' do
      journals = [ create(:journal, kid: kid),
                   create(:journal, kid: secondary_kid) ]
      teacher.todays_journals.sort.should eq(journals.sort)
    end

    it 'ignores foreign journals' do
      create(:journal)
      teacher.todays_journals.sort.should eq([])
    end

    it 'ignores older journals' do
      create(:journal, kid: kid, created_at: Date.parse("2000-01-01"))
      teacher.todays_journals.sort.should eq([])
    end

    it 'delivers journals email when journals available' do
      create(:journal, kid: kid)
      create(:journal, kid: secondary_kid)
      Teacher.conditionally_send_journals
      ActionMailer::Base.deliveries.size.should eq(1)
    end

    it 'does not deliver journals when no available' do
      Teacher.conditionally_send_journals
      ActionMailer::Base.deliveries.should be_empty
    end

    it 'does not deliver journals when opted out' do
      create(:journal, kid: kid)
      teacher.update_attributes(receive_journals: false)
      create(:journal)
      Teacher.conditionally_send_journals
      ActionMailer::Base.deliveries.should be_empty
    end

  end
end
