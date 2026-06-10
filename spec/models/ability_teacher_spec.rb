# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe 'A Teacher' do
    before do
      @teacher = create(:teacher)
      @ability = described_class.new(@teacher)
    end

    let(:foreign_teacher) { create(:teacher) }
    let(:kid) { create(:kid, teacher: @teacher) }
    let(:secondary_kid) { create(:kid, secondary_teacher: @teacher) }
    let(:third_kid) { create(:kid, third_teacher: @teacher) }
    let(:foreign_kid) { create(:kid) }
    let(:journal) { create(:journal, kid: kid) }
    let(:foreign_journal) { create(:journal, kid: foreign_kid) }
    let(:review) { create(:review, kid: kid) }

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

    it 'can read third assigned kid' do
      expect(@ability).to be_able_to(:read, third_kid)
    end

    it 'can update third assigned kid' do
      expect(@ability).to be_able_to(:update, third_kid)
    end

    it 'can create kids' do
      expect(@ability).to be_able_to(:create, Kid)
    end

    it 'cannot read assigned kid that is inactive' do
      kid.update!(inactive: true)
      expect(@ability).not_to be_able_to(:read, kid)
    end

    it 'cannot update assigned kid that is inactive' do
      kid.update!(inactive: true)
      expect(@ability).not_to be_able_to(:update, kid)
    end

    it 'cannot read foreign kid' do
      expect(@ability).not_to be_able_to(:read, foreign_kid)
    end

    it 'cannot update foreign kid' do
      expect(@ability).not_to be_able_to(:update, foreign_kid)
    end

    it 'cannot destroy inactive kid' do
      kid.update!(inactive: true)
      expect(@ability).not_to be_able_to(:destroy, kid)
    end

    it 'can read mentor of assigned kid' do
      mentor = create(:mentor)
      mentor.kids << kid
      expect(@ability).to be_able_to(:read, mentor)
    end

    it 'cannot read secondary mentor of assigned kid when secondary not active' do
      mentor = create(:mentor)
      mentor.secondary_kids << kid
      kid.update!(secondary_active: false)
      expect(@ability).not_to be_able_to(:read, mentor)
    end

    it 'can read secondary mentor of assigned kid when secondary active' do
      mentor = create(:mentor)
      mentor.secondary_kids << kid
      kid.update!(secondary_active: true)
      expect(@ability).to be_able_to(:read, mentor)
    end

    it 'can read mentor of assigned secondary kid' do
      mentor = create(:mentor)
      mentor.kids << secondary_kid
      expect(@ability).to be_able_to(:read, mentor)
    end

    it 'can read mentor of assigned third kid' do
      mentor = create(:mentor)
      mentor.kids << third_kid
      expect(@ability).to be_able_to(:read, mentor)
    end

    it 'can read secondary mentor of assigned third kid when secondary active' do
      mentor = create(:mentor)
      mentor.secondary_kids << third_kid
      third_kid.update!(secondary_active: true)
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
      expect(@ability).to be_able_to(:read, foreign_journal)
    end

    it 'can read journals of kids he is set as third teacher' do
      expect(@ability).to be_able_to(:read, create(:journal, kid: third_kid))
    end

    it 'cannot read journals of kids he is not set as teacher' do
      expect(@ability).not_to be_able_to(:read, foreign_journal)
    end

    it 'cannot read reviews of kids he is set as teacher' do
      expect(@ability).not_to be_able_to(:read, review)
    end

    context 'when the site config permits teachers to access reviews' do
      before do
        Site.load.update!(teachers_can_access_reviews: true)
        @ability = described_class.new(@teacher)
      end

      it 'can read reviews of kids he is set as teacher' do
        expect(@ability).to be_able_to(:read, review)
      end

      it 'can update reviews of kids he is set as teacher' do
        expect(@ability).to be_able_to(:update, review)
      end

      it 'can update reviews of kids he is set as secondary teacher' do
        expect(@ability).to be_able_to(:update, create(:review, kid: secondary_kid))
      end

      it 'can update reviews of kids he is set as third teacher' do
        expect(@ability).to be_able_to(:update, create(:review, kid: third_kid))
      end

      it 'cannot read reviews of foreign kids' do
        expect(@ability).not_to be_able_to(:read, create(:review, kid: foreign_kid))
      end

      # the review rules are defined before the global destroy protection,
      # so even with the site config enabled teachers must not destroy reviews
      it 'cannot destroy reviews of kids he is set as teacher' do
        expect(@ability).not_to be_able_to(:destroy, review)
      end
    end

    context 'termination assessments' do
      it 'can create termination assessments for kids he is set as teacher' do
        expect(@ability).to be_able_to(:create, build(:termination_assessment, kid: kid))
      end

      it 'can update termination assessments for kids he is set as teacher' do
        expect(@ability).to be_able_to(:update, build(:termination_assessment, kid: kid))
      end

      it 'can update termination assessments for kids he is set as secondary teacher' do
        expect(@ability).to be_able_to(:update, build(:termination_assessment, kid: secondary_kid))
      end

      it 'can update termination assessments for kids he is set as third teacher' do
        expect(@ability).to be_able_to(:update, build(:termination_assessment, kid: third_kid))
      end

      it 'cannot read termination assessments of foreign kids' do
        expect(@ability).not_to be_able_to(:read, build(:termination_assessment, kid: foreign_kid))
      end

      # the termination assessment rules are defined before the global
      # destroy protection, so destroy stays revoked
      it 'cannot destroy termination assessments for kids he is set as teacher' do
        expect(@ability).not_to be_able_to(:destroy, build(:termination_assessment, kid: kid))
      end
    end
  end
end
