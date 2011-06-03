require 'spec_helper'

describe Ability do

  describe "A Mentor" do
    let(:mentor) { Factory(:mentor)}
    let(:other_mentor) { Factory(:mentor)}
    let(:ability) { Ability.new(mentor) }
    it "can update its own record" do
      assert ability.can?(:update, mentor)
    end
    it "cannot destroy its own record" do
      assert ability.cannot?(:destroy, mentor)
    end
    it "cannot read other mentor records" do
      assert ability.cannot?(:read, other_mentor)
    end
    it "cannot read kid that does not belong to him" do
      kid = Factory(:kid)
      assert ability.cannot?(:read, kid)
    end
    it "can read kid where he is set as mentor" do
      kid = Factory(:kid, :mentor => mentor)
      assert ability.can?(:read, kid)
    end
    it "can read kid where he is set as secondary mentor" do
      kid = Factory(:kid, :secondary_mentor => mentor)
      assert ability.can?(:read, kid)
    end
    it "cannot access teachers in general" do
      assert ability.cannot?(:read, Teacher)
    end
    it "cannot access admins in general" do
      assert ability.cannot?(:read, Admin)
    end
    it "can access mentors in general" do
      assert ability.can?(:read, Mentor)
    end
    it "can access kids in general" do
      assert ability.can?(:read, Kid)
    end
  end

end
