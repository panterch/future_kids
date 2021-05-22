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
    let(:male_kid) { create(:kid, sex: 'm') }
    let(:female_kid) { create(:kid, sex: 'f') }
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
    let(:mentor_matching) { create(:mentor_matching, kid: kid, mentor: mentor) }
    let(:reserved_mentor_matching) { create(:mentor_matching, kid: kid, mentor: mentor, state: 'reserved') }

    context 'admin' do
      it 'cannot read foreign admin' do
        expect(ability).not_to be_able_to(:read, admin)
      end
      it 'can read own kids coach' do
        kid.update(admin: admin)
        expect(ability).to be_able_to(:read, admin)
      end
      it 'can read secondary kids coach' do
        secondary_kid.update(admin: admin)
        expect(ability).to be_able_to(:read, admin)
      end
      it 'never can update coaches' do
        kid.update(admin: admin)
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
      it 'cannot read & edit its state' do
        expect(ability).not_to be_able_to([:read, :update], mentor, :state)
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
      it 'does retrieve teachers that can be read' do
        teacher = create(:teacher, kids: [kid])
        expect(Teacher.accessible_by(ability, :read)).to eq([teacher])
      end
    end

    context 'available kids' do
      before do
        Site.load.update!(public_signups_active: true)
      end
      it 'can find only men' do
        expect(ability).to be_able_to(:search, male_kid)
        expect(ability).not_to be_able_to(:search, female_kid)
      end
    end

    context 'mentor matchings' do
      before do
        Site.load.update!(public_signups_active: true)
      end
      it 'cannot read mentor matchings' do
        expect(ability).not_to be_able_to(:read, mentor_matching)
      end

      it 'can read reserved mentor matchings' do
        expect(ability).to be_able_to(:read, reserved_mentor_matching)
      end
    end

    context 'various' do
      it 'cannot read schools' do
        expect(ability).not_to be_able_to(:read, create(:school))
      end
    end # end of tests for mentors
  end

end
