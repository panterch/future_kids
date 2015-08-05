require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe 'A Mentor' do
    let(:admin) { create(:admin) }
    let(:mentor) { create(:mentor) }
    let(:other_mentor) { create(:mentor) }
    let(:ability) { Ability.new(mentor) }
    let(:foreign_kid) { create(:kid) }
    let(:kid) { create(:kid, mentor: mentor) }
    let(:secondary_kid) do
      create(:kid, secondary_mentor: mentor,
                   secondary_active: true)
    end
    let(:journal) { create(:journal, kid: kid, mentor: mentor) }
    let(:foreign_journal) { create(:journal, kid: foreign_kid) }
    let(:direct_associated_journal) do
      create(:journal, kid: foreign_kid,
                       mentor: mentor)
    end
    let(:review) { build(:review, kid: kid) }

    context 'admin' do
      it 'cannot read foreign admin' do
        expect(ability).not_to be_able_to(:read, admin)
      end
      it 'can read own kids coach' do
        kid.update_attributes(admin: admin)
        expect(ability).to be_able_to(:read, admin)
      end
      it 'can read secondary kids coach' do
        secondary_kid.update_attributes(admin: admin)
        expect(ability).to be_able_to(:read, admin)
      end
      it 'never can update coaches' do
        kid.update_attributes(admin: admin)
        expect(ability).not_to be_able_to(:update, admin)
      end
    end

    context 'mentors' do
      it 'can access mentors in general' do
        expect(ability).to be_able_to(:read, Mentor)
      end
      it 'can update its own record' do
        expect(ability).to be_able_to(:update, mentor)
      end
      it 'cannot destroy its own record' do
        expect(ability).not_to be_able_to(:destroy, mentor)
      end
      it 'cannot read other mentor records' do
        expect(ability).not_to be_able_to(:read, other_mentor)
      end
      it 'can read other mentor records if they work with the same kid' do
        other_mentor.secondary_kids << kid
        expect(ability).to be_able_to(:read, other_mentor)
      end
      it 'can read other mentor records if he is secondary mentor on the same kid' do
        other_mentor.kids << secondary_kid
        expect(ability).to be_able_to(:read, other_mentor)
      end
      it 'can edit its schedules' do
        expect(ability).to be_able_to(:edit_schedules, mentor)
      end
      it 'cannot edit foreign mentors schedules' do
        expect(ability).not_to be_able_to(:edit_schedules, other_mentor)
      end
    end

    context 'kids' do
      it 'can access kids in general' do
        expect(ability).to be_able_to(:read, Kid)
      end
      it 'cannot read kid that does not belong to him' do
        kid = create(:kid)
        expect(ability).not_to be_able_to(:read, foreign_kid)
      end
      it 'can read kid where he is set as mentor' do
        expect(ability).to be_able_to(:read, kid)
      end
      it 'cannot edit kids schedules' do
        expect(ability).not_to be_able_to(:edit_schedules, kid)
      end
      it 'cannot update kid where he is set as mentor' do
        expect(ability).not_to be_able_to(:update, kid)
      end
      it 'can read kid where he is set as secondary mentor' do
        expect(ability).to be_able_to(:read, secondary_kid)
      end
      it 'cannot read kid where he is set as secondary inactive' do
        inactive_kid = create(:kid, secondary_mentor: mentor,
                                    secondary_active: false)
        expect(ability).not_to be_able_to(:read, inactive_kid)
      end
    end

    context 'journal as primary mentor' do
      it 'can read journals of kids he is set as mentor' do
        expect(ability).to be_able_to(:read, journal)
      end
      it 'cannot destroy journals of he is directly associated' do
        expect(ability).to be_able_to(:destroy, journal)
      end
      it 'can update journals of he is directly associated' do
        expect(ability).to be_able_to(:update, journal)
      end
    end

    context 'journal as secondary mentor' do
      it 'can read journals of other mentors where he is set as secondary' do
        journal = create(:journal, kid: secondary_kid)
        expect(ability).to be_able_to(:read, journal)
      end
      it 'cannot read journals where he is not set active as secondary' do
        inactive_secondary_kid = create(:kid, secondary_mentor: mentor,
                                              secondary_active: false)
        journal = create(:journal, kid: inactive_secondary_kid)
        expect(ability).not_to be_able_to(:read, journal)
      end
      it 'can update journals where he is set active as secondary' do
        journal = create(:journal, kid: secondary_kid, mentor: mentor)
        expect(ability).to be_able_to(:update, journal)
      end
      it 'can destroy journals where he is set active as secondary' do
        journal = create(:journal, kid: secondary_kid, mentor: mentor)
        expect(ability).to be_able_to(:destroy, journal)
      end
      it 'cannot update journals where he is not set active as secondary' do
        inactive_secondary_kid = create(:kid, secondary_mentor: mentor,
                                              secondary_active: false)
        journal = create(:journal, kid: inactive_secondary_kid, mentor: mentor)
        expect(ability).not_to be_able_to(:update, journal)
        expect(ability).not_to be_able_to(:destroy, journal)
      end
    end

    context 'journals associated otherwise' do
      it 'cannot read journals where he is not set as mentor' do
        expect(ability).not_to be_able_to(:read, foreign_journal)
      end
      it 'can read a foreign journal when he is set as mentor on it' do
        expect(ability).to be_able_to(:read, direct_associated_journal)
      end
      it 'does retrieve all journals that can be read' do
        journal && foreign_journal && direct_associated_journal
        journals = Journal.accessible_by(ability, :read)
        expect(journals).to include(journal)
        expect(journals).to include(direct_associated_journal)
        expect(journals).not_to include(foreign_journal)
      end
    end

    context 'review' do
      it 'can create reviews for kids he is set as mentor' do
        expect(ability).to be_able_to(:create, review)
      end
      it 'can update reviews for kids he is set as mentor' do
        expect(ability).to be_able_to(:update, review)
      end
      it 'cannot destroy reviews for kids he is set as mentor' do
        expect(ability).not_to be_able_to(:destroy, review)
      end
      it 'cannot create reviews for kids he is not associated' do
        review = build(:review, kid: foreign_kid)
        expect(ability).not_to be_able_to(:create, review)
      end
      it 'cannot read reviews for kids he is set as secondary mentor' do
        review = build(:review, kid: secondary_kid)
        expect(ability).not_to be_able_to(:read, review)
      end
    end

    context 'teacher' do
      it 'cannot read foreign teachers' do
        expect(ability).not_to be_able_to(:read, create(:teacher))
      end
      it 'can read teacher of assigned kid' do
        expect(ability).to be_able_to(:read, create(:teacher, kids: [kid]))
      end
      it 'can read secondary teacher of assigned kid' do
        expect(ability).to be_able_to(:read, create(:teacher, secondary_kids: [kid]))
      end
      it 'can read teacher of secondary kid' do
        expect(ability).to be_able_to(:read, create(:teacher, kids: [secondary_kid]))
      end
      it 'can read secondary teacher of secondary kid' do
        expect(ability).to be_able_to(:read, create(:teacher,
                                                    secondary_kids: [secondary_kid]))
      end
      # FIXME cancan accessible_by for mentor - teacher relation
      # this test does not work, this seems to be a problem in cancan...
      it 'does retrieve teachers that can be read' do
        skip('accessible_by mentor - teacher broken')
        teacher = create(:teacher, kids: [kid])
        expect(Teacher.accessible_by(ability, :read)).to eq([teacher])
      end
    end

    context 'various' do
      it 'cannot read schools' do
        expect(ability).not_to be_able_to(:read, create(:school))
      end
    end # end of tests for mentors
  end

  describe 'An admin' do
    before(:each) do
      @admin = create(:admin)
      @ability = Ability.new(@admin)
    end

    context 'kid' do
      let(:kid) { create(:kid) }
      it('can read a kid') { expect(@ability).to be_able_to(:read, kid) }
      it('can create a kid') { expect(@ability).to be_able_to(:create, Kid) }
      it('can update a kid') { expect(@ability).to be_able_to(:update, kid) }
      it('cannot destroy a kid') { expect(@ability).not_to be_able_to(:destroy, kid) }
    end

    context 'school' do
      let(:school) { create(:school) }
      it('can read a school') { expect(@ability).to be_able_to(:read, school) }
      it('can create a school') { expect(@ability).to be_able_to(:create, School) }
    end
  end # end of tests for admin role

  describe 'A Teacher' do
    before(:each) do
      @teacher = create(:teacher)
      @ability = Ability.new(@teacher)
    end
    let(:foreign_teacher) { create(:teacher) }
    let(:kid) { create(:kid, teacher: @teacher) }
    let(:secondary_kid) { create(:kid, secondary_teacher: @teacher) }
    let(:foreign_kid) { create(:kid) }
    let(:journal) { create(:journal, kid: kid) }
    let(:foreign_journal) { create(:journal, kid: foreign_kid) }

    it 'cannot access teachers in general' do
      expect(@ability).not_to be_able_to(:read, foreign_teacher)
    end
    it 'can update its own record' do
      expect(@ability).to be_able_to(:update, @teacher)
    end
    it 'can read assigned kid' do
      expect(@ability).to be_able_to(:read, kid)
    end
    it 'can update assigned kid' do
      expect(@ability).to be_able_to(:update, kid)
    end
    it 'cannot edit schedules of assigned kid' do
      expect(@ability).not_to be_able_to(:edit_schedules, kid)
    end
    it 'can read secondary assigned kid' do
      expect(@ability).to be_able_to(:read, secondary_kid)
    end
    it 'can update secondary assigned kid' do
      expect(@ability).to be_able_to(:update, secondary_kid)
    end
    it 'cannot read foreign kid' do
      expect(@ability).not_to be_able_to(:read, foreign_kid)
    end
    it 'cannot update foreign kid' do
      expect(@ability).not_to be_able_to(:update, foreign_kid)
    end
    it 'can read mentor of assigned kid' do
      mentor = create(:mentor)
      mentor.kids << kid
      expect(@ability).to be_able_to(:read, mentor)
    end
    it 'cannot read secondary mentor of assigned kid when secondary not active' do
      mentor = create(:mentor)
      mentor.secondary_kids << kid
      kid.update_attribute(:secondary_active, false)
      expect(@ability).not_to be_able_to(:read, mentor)
    end
    it 'can read secondary mentor of assigned kid when secondary active' do
      mentor = create(:mentor)
      mentor.secondary_kids << kid
      kid.update_attribute(:secondary_active, true)
      expect(@ability).to be_able_to(:read, mentor)
    end
    it 'can read mentor of assigned secondary kid' do
      mentor = create(:mentor)
      mentor.kids << secondary_kid
      expect(@ability).to be_able_to(:read, mentor)
    end
    it 'cannot read foreign mentor' do
      expect(@ability).not_to be_able_to(:read, create(:mentor))
    end
    it 'fetches only assigned kids' do
      kid && secondary_kid && foreign_kid # trigger factory
      expect(Kid.accessible_by(@ability, :read)).to eq([kid, secondary_kid])
    end
    it 'can read journals of kids he is set as teacher' do
      expect(@ability).to be_able_to(:read, journal)
    end
    it 'can read journals of kids he is set as secondary teacher' do
      foreign_journal.kid.secondary_teacher = @teacher
      foreign_journal.kid.save!
      expect(@ability).to be_able_to(:read, journal)
    end
    it 'cannot read journals of kids he is not set as teacher' do
      expect(@ability).not_to be_able_to(:read, foreign_journal)
    end
  end

  describe 'Principal' do
    before(:each) do
      @principal = create(:principal)
      @school = @principal.schools.first
      @ability = Ability.new(@principal)
    end

    it 'can read his own data' do
      expect(@ability).to be_able_to(:read, @principal)
    end
    it 'cannot read other principals data' do
      expect(@ability).not_to be_able_to(:update, create(:principal))
    end
    it 'can update its own record' do
      expect(@ability).to be_able_to(:update, @principal)
    end

    it 'cannot access foreign kids' do
      expect(@ability).not_to be_able_to(:read, create(:kid))
    end
    it 'can read own schools kids' do
      expect(@ability).to be_able_to(:read, create(:kid, school: @school))
    end
    it 'cannot read own schools inactive kids' do
      expect(@ability).not_to be_able_to(:read, create(:kid, school: @school,
                                                             inactive: true))
    end
    it 'cannot edit own schools kids' do
      expect(@ability).not_to be_able_to(:edit, create(:kid, school: @school))
    end
    it 'cannot update own schools kids' do
      expect(@ability).not_to be_able_to(:update, create(:kid, school: @school))
    end

    it 'cannot read teachers of other schools' do
      expect(@ability).not_to be_able_to(:read, create(:teacher))
    end
    it 'can read teachers of own school' do
      expect(@ability).to be_able_to(:read, create(:teacher, school: @school))
    end
  end
end
