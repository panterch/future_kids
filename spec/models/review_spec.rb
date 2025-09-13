require 'spec_helper'

describe Review do
  context 'dates' do
    subject { build(:review) }

    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:held_at) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:held_at) }
  end
end
