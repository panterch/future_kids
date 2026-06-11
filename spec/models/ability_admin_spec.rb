# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe 'An admin' do
    before do
      @admin = create(:admin)
      @ability = described_class.new(@admin)
    end

    context 'kid' do
      let(:kid) { create(:kid) }

      it('can read a kid') { expect(@ability).to be_able_to(:read, kid) }
      it('can create a kid') { expect(@ability).to be_able_to(:create, Kid) }
      it('can update a kid') { expect(@ability).to be_able_to(:update, kid) }
      it('cannot destroy a kid') { expect(@ability).not_to be_able_to(:destroy, kid) }

      it('can destroy an inactive kid') do
        kid.update!(inactive: true)
        expect(@ability).to be_able_to(:destroy, kid)
      end
    end

    context 'school' do
      let(:school) { create(:school) }

      it('can read a school') { expect(@ability).to be_able_to(:read, school) }
      it('can create a school') { expect(@ability).to be_able_to(:create, School) }

      # representative proof that the global destroy protection also binds
      # admins despite `can :manage, :all`
      it('cannot destroy a school') { expect(@ability).not_to be_able_to(:destroy, school) }
    end

    context 'destroy exceptions' do
      it('can destroy reminders') { expect(@ability).to be_able_to(:destroy, build(:reminder)) }
      it('can destroy documents') { expect(@ability).to be_able_to(:destroy, build(:document)) }
      it('can destroy journals') { expect(@ability).to be_able_to(:destroy, build(:journal)) }
      it('can destroy kid mentor relations') { expect(@ability).to be_able_to(:destroy, KidMentorRelation) }
      it('can destroy reviews') { expect(@ability).to be_able_to(:destroy, build(:review)) }

      it('can destroy first year assessments') do
        expect(@ability).to be_able_to(:destroy, build(:first_year_assessment))
      end

      it('can destroy termination assessments') do
        expect(@ability).to be_able_to(:destroy, build(:termination_assessment))
      end

      it('can destroy an inactive teacher') do
        expect(@ability).to be_able_to(:destroy, create(:teacher, inactive: true))
      end

      it('cannot destroy an active teacher') do
        expect(@ability).not_to be_able_to(:destroy, create(:teacher))
      end

      it('cannot destroy a mentor') do
        expect(@ability).not_to be_able_to(:destroy, create(:mentor))
      end
    end

    context 'reminder' do
      # reminders are only created by a batch job, even admins must not
      # create them manually
      it('cannot create reminders') { expect(@ability).not_to be_able_to(:create, Reminder) }
    end

    context 'document' do
      it('can read admin only documents') do
        expect(@ability).to be_able_to(:read, build(:document, admin_only: true))
      end
    end
  end
end
