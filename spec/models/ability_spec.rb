require 'spec_helper'

describe Ability do

  describe "A Mentor" do
    let(:mentor) { Factory(:mentor)}
    let(:other_mentor) { Factory(:mentor)}
    let(:ability) { Ability.new(mentor) }
    let(:foreign_kid) { Factory(:kid) }
    let(:kid) { Factory(:kid, :mentor => mentor) }
    let(:secondary_kid) { Factory(:kid, :secondary_mentor => mentor) }
    let(:journal) { Factory(:journal, :kid => kid, :mentor => mentor) }
    let(:foreign_journal) { Factory(:journal, :kid => foreign_kid) }
    let(:direct_associated_journal) { Factory(:journal, :kid => foreign_kid,
                                              :mentor => mentor) }
    let(:review) { Factory.build(:review, :kid => kid) }
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
      it "can update journals of he is directly associated" do
        assert ability.can?(:update, journal)
      end
      it "cannot destroy journals of he is directly associated" do
        assert ability.cannot?(:destroy, journal)
      end
      it "cannot read journals where he is not set as mentor" do
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

      context "review" do
        it "can create reviews for kids he is set as mentor" do
          assert ability.can?(:create, review)
        end
        it "can update reviews for kids he is set as mentor" do
          assert ability.can?(:update, review)
        end
        it "cannot destroy reviews for kids he is set as mentor" do
          assert ability.cannot?(:destroy, review)
        end
        it "cannot create reviews for kids he is not associated" do
          review = Factory.build(:review, :kid => foreign_kid)
          assert ability.cannot?(:create, review)
        end
      end

    end # end of tests for mentors

    context "An admin" do
      before(:each) do
        @admin = Factory(:admin)
        @ability = Ability.new(@admin)
      end

      context "kid" do
        let(:kid) { Factory(:kid) }
        it("can read a kid") { assert @ability.can?(:read, Kid) }
        it("can create a kid") { assert @ability.can?(:create, Kid) }
        it("can update a kid") { assert @ability.can?(:update, Kid) }
        it("cannot destroy a kid") { assert @ability.cannot?(:destroy, Kid) }
      end
    end # end of tests for admin role

    context "teacher" do
      it "cannot access teachers in general" do
        assert ability.cannot?(:read, Teacher)
      end
    end

  end

end
