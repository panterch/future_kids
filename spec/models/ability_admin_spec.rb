require 'spec_helper'
require 'cancan/matchers'

describe Ability do

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
      it('can destroy an inactive kid') do
        kid.update!(inactive: true)
        expect(@ability).to be_able_to(:destroy, kid)
      end
    end

    context 'school' do
      let(:school) { create(:school) }
      it('can read a school') { expect(@ability).to be_able_to(:read, school) }
      it('can create a school') { expect(@ability).to be_able_to(:create, School) }
    end

    context 'mentor matchings' do
      let(:mentor_matching) { create(:mentor_matching, kid: create(:kid), mentor: create(:mentor)) }
      it('can read a mentor matchings') { expect(@ability).to be_able_to(:read, mentor_matching) }
    end
  end # end of tests for admin role

end
