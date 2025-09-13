require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe 'Principal' do
    before do
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

    it 'can read own schools inactive kids' do
      expect(@ability).to be_able_to(:read, create(:kid, school: @school, inactive: true))
    end

    it 'cannot edit own schools kids' do
      expect(@ability).to be_able_to(:edit, create(:kid, school: @school))
    end

    it 'cannot update own schools kids' do
      expect(@ability).to be_able_to(:update, create(:kid, school: @school))
    end

    it 'cannot edit foreign schools kids' do
      expect(@ability).not_to be_able_to(:edit, create(:kid))
    end

    it 'cannot update foreign schools kids' do
      expect(@ability).not_to be_able_to(:update, create(:kid))
    end

    it 'cannot read teachers of other schools' do
      expect(@ability).not_to be_able_to(:read, create(:teacher))
    end

    it 'can read teachers of own school' do
      expect(@ability).to be_able_to(:read, create(:teacher, school: @school))
    end

    it 'can update teachers of its own scool' do
      expect(@ability).to be_able_to(:update, create(:teacher, school: @school))
    end
  end
end
