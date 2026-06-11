# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe 'Principal' do
    before do
      @principal = create(:principal)
      @school = @principal.schools.first
      @ability = described_class.new(@principal)
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

    it 'can read own schools inactive kids' do
      expect(@ability).to be_able_to(:read, create(:kid, school: @school, inactive: true))
    end

    it 'can edit own schools kids' do
      expect(@ability).to be_able_to(:edit, create(:kid, school: @school))
    end

    it 'can update own schools kids' do
      expect(@ability).to be_able_to(:update, create(:kid, school: @school))
    end

    it 'cannot edit foreign schools kids' do
      expect(@ability).not_to be_able_to(:edit, create(:kid))
    end

    it 'cannot update foreign schools kids' do
      expect(@ability).not_to be_able_to(:update, create(:kid))
    end

    it 'can create kids' do
      expect(@ability).to be_able_to(:create, Kid)
    end

    it 'cannot destroy own schools kids' do
      expect(@ability).not_to be_able_to(:destroy, create(:kid, school: @school))
    end

    it 'cannot read teachers of other schools' do
      expect(@ability).not_to be_able_to(:read, create(:teacher))
    end

    it 'cannot update teachers of other schools' do
      expect(@ability).not_to be_able_to(:update, create(:teacher))
    end

    it 'can read teachers of own school' do
      expect(@ability).to be_able_to(:read, create(:teacher, school: @school))
    end

    it 'can update teachers of its own scool' do
      expect(@ability).to be_able_to(:update, create(:teacher, school: @school))
    end

    it 'can create teachers' do
      expect(@ability).to be_able_to(:create, Teacher)
    end

    it 'cannot read inactive teachers of own school' do
      expect(@ability).not_to be_able_to(:read, create(:teacher, school: @school, inactive: true))
    end

    it 'cannot destroy teachers of own school' do
      expect(@ability).not_to be_able_to(:destroy, create(:teacher, school: @school))
    end

    it 'cannot destroy its own record' do
      expect(@ability).not_to be_able_to(:destroy, @principal)
    end

    # principals have no access to journals, reviews, assessments or mentors,
    # not even for kids of their own schools
    context 'with a kid of his own school' do
      before do
        @kid = create(:kid, school: @school, mentor: create(:mentor))
      end

      it 'cannot read journals' do
        expect(@ability).not_to be_able_to(:read, create(:journal, kid: @kid))
      end

      it 'cannot read reviews' do
        expect(@ability).not_to be_able_to(:read, create(:review, kid: @kid))
      end

      it 'cannot read first year assessments' do
        expect(@ability).not_to be_able_to(:read, create(:first_year_assessment, kid: @kid))
      end

      it 'cannot read termination assessments' do
        expect(@ability).not_to be_able_to(:read, build(:termination_assessment, kid: @kid))
      end

      it 'cannot read the kids mentor' do
        expect(@ability).not_to be_able_to(:read, @kid.mentor)
      end
    end

    it 'cannot read admin only documents' do
      expect(@ability).not_to be_able_to(:read, build(:document, admin_only: true))
    end

    context 'with multiple schools' do
      before do
        @second_school = create(:school)
        @principal.schools << @second_school
        @ability = described_class.new(@principal)
      end

      it 'can update kids of both schools' do
        expect(@ability).to be_able_to(:update, create(:kid, school: @school))
        expect(@ability).to be_able_to(:update, create(:kid, school: @second_school))
      end

      it 'can update teachers of both schools' do
        expect(@ability).to be_able_to(:update, create(:teacher, school: @school))
        expect(@ability).to be_able_to(:update, create(:teacher, school: @second_school))
      end
    end
  end
end
