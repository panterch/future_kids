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
  end

end
