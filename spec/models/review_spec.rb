require 'spec_helper'

describe Review do

  context 'dates' do
    subject { build(:review) }

    it { should allow_values(Date.parse('2021-11-18')).for(:held_at) }
    it { should_not allow_values(Date.parse('0021-11-18')).for(:held_at) }
  end

end
