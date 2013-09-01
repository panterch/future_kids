require 'spec_helper'

describe Mentor do
  it 'has a valid factory' do
    mentor = Factory.build(:mentor)
    mentor.should be_valid
  end

  context 'validations' do
    let(:mentor) { Factory(:mentor) }
    it 'does not require password again' do
      mentor.should be_valid
    end
    it 'does ignore password overwrite with nil' do
      mentor.password = mentor.password_confirmation = nil
      mentor.should be_valid
    end
    # devise triggers an error when empty passwords are entered. but this
    # is the default when submitting a form
    it 'does trigger an error on blank password' do
      mentor.password = mentor.password_confirmation = ''
      mentor.should be_valid
    end
    it 'does not allow nil password on unsaved mentor' do
      new_mentor = Factory.build(:mentor)
      new_mentor.password = new_mentor.password_confirmation = nil
      new_mentor.should_not be_valid
    end
  end

  context 'schedules association' do
    it 'should create associated schedules' do
      @mentor = Factory(:mentor)
      @mentor.update_attributes(:schedules_attributes => [
         { :day => 1, :hour => 15, :minute => 0 },
         { :day => 2, :hour => 16, :minute => 30 }
      ])
      @mentor.reload.schedules.count.should eq(2)
    end
  end

  context 'mentors grouped bu assigned kids' do
    it 'does correctly group' do
      @both = Factory(:mentor)
      Factory(:kid, :mentor => @both)
      Factory(:kid, :secondary_mentor => @both)
      @only_primary = Factory(:mentor)
      Factory(:kid, :mentor => @only_primary)
      @only_secondary = Factory(:mentor)
      Factory(:kid, :secondary_mentor => @only_secondary)
      @substitute = Factory(:mentor, :substitute => true)
      @none = Factory(:mentor)

      res = Mentor.mentors_grouped_by_assigned_kids
      assert_equal [@both], res[:both]
      assert_equal [@only_primary], res[:only_primary]
      assert_equal [@only_secondary], res[:only_secondary]
      assert_equal [@substitute], res[:substitute]
      assert_equal [@none], res[:none]
    end
  end

  context 'inactive setting' do
    it 'should release kids when set inactive' do
      @mentor = Factory(:mentor)
      Factory(:kid, :mentor => @mentor)
      Factory(:kid, :secondary_mentor => @mentor)
      @mentor.reload.update_attributes(:inactive => true)
      @mentor.reload.kids.count.should eq(0)
      @mentor.secondary_kids.count.should eq(0)
    end
  end

  context 'total minutes' do
    it 'should count journals' do
      @mentor = Factory(:mentor)
      @journal = Factory(:journal, :mentor => @mentor,
        :start_at => Time.parse("13:00"),
        :end_at  => Time.parse("14:30"))
      @mentor.total_duration.should eq(90)
    end
  end

  context 'month_count' do
    it 'counts journals per month' do
      @mentor = Factory(:mentor)
      Factory(:journal, :mentor => @mentor,
              :held_at => Date.parse("2011-05-30"))
      Factory(:journal, :mentor => @mentor,
              :held_at => Date.parse("2011-06-01"))
      @mentor.month_count.should eq(2)
    end

    it 'counts two journals in month once' do
      @mentor = Factory(:mentor)
      Factory(:journal, :mentor => @mentor,
              :held_at => Date.parse("2011-05-30"))
      Factory(:journal, :mentor => @mentor,
              :held_at => Date.parse("2011-05-01"))
      @mentor.month_count.should eq(1)
    end
  end

  context "has attached file photo" do
    before do
      @file = File.new(Rails.root.join('spec/fixtures/logo.png'))
      @mentor = Factory.build(:mentor)
    end
    it 'attaches a photo' do
      @mentor.photo = @file
      @mentor.save! ; @mentor = Mentor.first
      @mentor.photo.should be_present
      @mentor.photo.url(:thumb).should match(/logo\.png/)
    end
  end

end
