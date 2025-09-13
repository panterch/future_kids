require 'spec_helper'

describe Journal do
  it 'calculates duration' do
    j = create(:journal, start_at: '14:00', end_at: '14:30')
    expect(j.duration).to eq(30)
  end

  it 'calculates the year' do
    j = create(:journal, held_at: Date.parse('2010-12-31'))
    expect(j.year).to eq(2010)
  end

  it 'calculates week end of year' do
    j = create(:journal, held_at: Date.parse('2010-12-31'))
    expect(j.week).to eq(52)
  end

  it 'calculates week begin of year' do
    j = create(:journal, held_at: '2010-01-01')
    expect(j.week).to eq(0)
  end

  it 'creates a coaching entry at the end of the month' do
    mentor = build(:mentor)
    j = Journal.coaching_entry(mentor, '2', '2009')
    expect(j.held_at).to eq(Date.parse('2009-02-28'))
  end

  context 'dates' do
    subject { build(:journal) }

    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:held_at) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:held_at) }
  end
end
