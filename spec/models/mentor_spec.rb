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

  context 'mentors grouped bu assigned kids' do
    it 'does correctly group' do
      @both = Factory(:mentor)
      Factory(:kid, :mentor => @both)
      Factory(:kid, :secondary_mentor => @both)
      @only_primary = Factory(:mentor)
      Factory(:kid, :mentor => @only_primary)
      @only_secondary = Factory(:mentor)
      Factory(:kid, :secondary_mentor => @only_secondary)
      @none = Factory(:mentor)

      res = Mentor.mentors_grouped_by_assigned_kids
      assert_equal [@both], res[:both]
      assert_equal [@only_primary], res[:only_primary]
      assert_equal [@only_secondary], res[:only_secondary]
      assert_equal [@none], res[:none]
    end
  end
end
