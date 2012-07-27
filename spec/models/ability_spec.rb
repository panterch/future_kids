require 'spec_helper'

describe Ability do

  describe "A Mentor" do
    let(:mentor) { Factory(:mentor)}
    let(:other_mentor) { Factory(:mentor)}
    let(:ability) { Ability.new(mentor) }
    let(:foreign_kid) { Factory(:kid) }
    let(:kid) { Factory(:kid, :mentor => mentor) }
    let(:secondary_kid) { Factory(:kid, :secondary_mentor => mentor,
                                        :secondary_active => true ) }
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
      it "can read other mentor records if they work with the same kid" do
        other_mentor.secondary_kids << kid
        assert ability.can?(:read, other_mentor)
      end
      it "can read other mentor records if he is secondary mentor on the same kid" do
        other_mentor.kids << secondary_kid
        assert ability.can?(:read, other_mentor)
      end
      it "can edit its schedules" do
        assert ability.can?(:edit_schedules, mentor)
      end
      it "cannot edit foreign mentors schedules" do
        assert ability.cannot?(:edit_schedules, other_mentor)
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
      it "cannot edit kids schedules" do
        assert ability.cannot?(:edit_schedules, kid)
      end
      it "cannot update kid where he is set as mentor" do
        assert ability.cannot?(:update, kid)
      end
      it "can read kid where he is set as secondary mentor" do
        assert ability.can?(:read, secondary_kid)
      end
      it "cannot read kid where he is set as secondary inactive" do
        inactive_kid = Factory(:kid, :secondary_mentor => mentor,
                                     :secondary_active => false)
        assert ability.cannot?(:read, inactive_kid)
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
      it "can read journals of other mentors where he is set as secondary" do
        journal = Factory(:journal, :kid => secondary_kid)
        assert ability.can?(:read, journal)
      end
      it "cannot read journals wher he is not set active as secondary" do
        inactive_secondary_kid = Factory(:kid, :secondary_mentor => mentor,
                                         :secondary_active => false )
        journal = Factory(:journal, :kid => inactive_secondary_kid)
        assert ability.cannot?(:read, journal)
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
        it "cannot read reviews for kids he is set as secondary mentor" do
          review = Factory.build(:review, :kid => secondary_kid)
          assert ability.cannot?(:read, review)
        end
      end

      context "teacher" do
        it "cannot read foreign teachers" do
          assert ability.cannot?(:read, Factory(:teacher))
        end
        it "can read teacher of assigned kid" do
          assert ability.can?(:read, Factory(:teacher, :kids => [kid]))
        end
        it "can read secondary teacher of assigned kid" do
          assert ability.can?(:read, Factory(:teacher, :secondary_kids => [kid]))
        end
        it "can read teacher of secondary kid" do
          assert ability.can?(:read, Factory(:teacher, :kids => [secondary_kid]))
        end
        it "can read secondary teacher of secondary kid" do
          assert ability.can?(:read, Factory(:teacher,
                                             :secondary_kids => [secondary_kid]))
        end
        # FIXME cancan accessible_by for mentor - teacher relation
        # this test does not work, this seems to be a problem in cancan...
        # it "does retrieve teachers that can be read" do
        #   teacher = Factory(:teacher, :kids => [kid])
        #   Teacher.accessible_by(ability, :read).should eq([teacher])
        # end
      end

    end # end of tests for mentors
  end

  describe "An admin" do
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

  describe "teacher" do
    before(:each) do
      @teacher = Factory(:teacher)
      @ability = Ability.new(@teacher)
    end
    let(:foreign_teacher) { Factory(:teacher) }
    let(:kid) { Factory(:kid, :teacher => @teacher) }
    let(:secondary_kid) { Factory(:kid, :secondary_teacher => @teacher) }
    let(:foreign_kid) { Factory(:kid) }
    let(:journal) { Factory(:journal, :kid => kid) }
    let(:foreign_journal) { Factory(:journal, :kid => foreign_kid) }

    it "cannot access teachers in general" do
      assert @ability.cannot?(:read, foreign_teacher)
    end
    it "can update its own record" do
      assert @ability.can?(:update, @teacher)
    end
    it "can read assigned kid" do
      assert @ability.can?(:read, kid)
    end
    it "can update assigned kid" do
      assert @ability.can?(:update, kid)
    end
    it "cannot edit schedules of assigned kid" do
      assert @ability.cannot?(:edit_schedules, kid)
    end
    it "can read secondary assigned kid" do
      assert @ability.can?(:read, secondary_kid)
    end
    it "cannot read foreign kid" do
      assert @ability.cannot?(:read, foreign_kid)
    end
    it "cannot update foreign kid" do
      assert @ability.cannot?(:update, foreign_kid)
    end
    it "can read mentor of assigned kid" do
      mentor = Factory(:mentor)
      mentor.kids << kid
      assert @ability.can?(:read, mentor)
    end
    it "cannot read secondary mentor of assigned kid when secondary not active" do
      mentor = Factory(:mentor)
      mentor.secondary_kids << kid
      kid.update_attribute(:secondary_active, false)
      assert @ability.cannot?(:read, mentor)
    end
    it "can read secondary mentor of assigned kid when secondary active" do
      mentor = Factory(:mentor)
      mentor.secondary_kids << kid
      kid.update_attribute(:secondary_active, true)
      assert @ability.can?(:read, mentor)
    end
    it "can read mentor of assigned secondary kid" do
      mentor = Factory(:mentor)
      mentor.kids << secondary_kid
      assert @ability.can?(:read, mentor)
    end
    it "cannot read foreign mentor" do
      assert @ability.cannot?(:read, Factory(:mentor))
    end
    it "fetches only assigned kids" do
      kid && secondary_kid && foreign_kid # trigger factory
      Kid.accessible_by(@ability, :read).should eq([kid, secondary_kid])
    end
    it "can read journals of kids he is set as teacher" do
      assert @ability.can?(:read, journal)
    end
    it "can read journals of kids he is set as secondary teacher" do
      foreign_journal.kid.secondary_teacher = @teacher
      foreign_journal.kid.save!
      assert @ability.can?(:read, journal)
    end
    it "cannot read journals of kids he is not set as teacher" do
      assert @ability.cannot?(:read, foreign_journal)
    end
  end

end
