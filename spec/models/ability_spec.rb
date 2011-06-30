require 'spec_helper'

describe Ability do

  describe "A Mentor" do
    let(:mentor) { Factory(:mentor)}
    let(:other_mentor) { Factory(:mentor)}
    let(:ability) { Ability.new(mentor) }
    let(:foreign_kid) { Factory(:kid) }
    let(:kid) { Factory(:kid, :mentor => mentor) }
    let(:secondary_kid) { Factory(:kid, :secondary_mentor => mentor) }
    let(:journal) { Factory(:journal, :kid => kid) }
    let(:foreign_journal) { Factory(:journal, :kid => foreign_kid) }
    let(:direct_associated_journal) { Factory(:journal, :kid => foreign_kid,
                                              :mentor => mentor) }

    context "mentors" do
      it "can access mentors in general" do
        assert ability.can?(:read, Mentor)
      end
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

    context "kids" do
      it "can access kids in general" do
        assert ability.can?(:read, Kid)
      end
      it "cannot read kid that does not belong to him" do
        kid = Factory(:kid)
        assert ability.cannot?(:read, foreign_kid)
      end
      it "can read kid where he is set as mentor" do
        assert ability.can?(:read, kid)
      end
      it "cannot update kid where he is set as mentor" do
        assert ability.cannot?(:update, kid)
      end
      it "can read kid where he is set as secondary mentor" do
        assert ability.can?(:read, secondary_kid)
      end
    end

    context "journal" do
      it "can read journals of kids he is set as mentor" do
        assert ability.can?(:read, journal)
      end
      it "cannot read journals where he is set as mentor" do
        assert ability.cannot?(:read, foreign_journal)
      end
      it "can read a foreign journal when he is set as mentor on it" do
        assert ability.can?(:read, direct_associated_journal)
      end
      it "does retrieve all journals that can be read" do
        journal && foreign_journal && direct_associated_journal
        journals = Journal.accessible_by(ability, :read)
        assert journals.include?(journal)
        assert journals.include?(direct_associated_journal)
        assert !journals.include?(foreign_journal)
      end
    end

    context "teacher" do
      it "cannot access teachers in general" do
        assert ability.cannot?(:read, Teacher)
      end
    end

    context "admin" do
      it "cannot access admins in general" do
        assert ability.cannot?(:read, Admin)
      end
    end

  end

end
