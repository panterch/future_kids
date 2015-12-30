require 'spec_helper'

describe Schedule do
  let(:kid) { create(:kid) }
  let(:mentor) { create(:mentor) }

  it 'should belong to a mentor' do
    mentor.schedules.create!(day: 1, hour: 13, minute: 0)
    expect(mentor.reload.schedules).not_to be_empty
  end

  it 'should belong to a kid' do
    kid.schedules.create!(day: 1, hour: 13, minute: 0)
    expect(kid.reload.schedules).not_to be_empty
  end

  it 'should does not create the same entry twice' do
    mentor.schedules.create!(day: 1, hour: 13, minute: 0)
    expect { mentor.schedules.create!(day: 1, hour: 13, minute: 0) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'builds schedules for a whole week' do
    week = Schedule.build_week
    expect(week.length).to eq(5)
    # days * hours * halfhours
    expect(week.flatten.length).to eq(5 * 6 * 2)
  end

  context 'equality and enumerable methods' do
    it 'is not same time when minute differs' do
      one = build(:schedule, minute: 1)
      two = build(:schedule, minute: 2)
      expect(one).not_to eq two
    end
    it 'is not same time when all fields match' do
      one = build(:schedule)
      two = build(:schedule)
      expect(one).to eq two
    end
    it 'includes when times matches' do
      collection = [build(:schedule, minute: 1),
                    build(:schedule, minute: 2)]
      expect(collection).to include(build(:schedule, minute: 1))
    end
    it 'includes does not include when times do not match' do
      collection = [build(:schedule, minute: 1),
                    build(:schedule, minute: 2)]
      expect(collection).not_to include(build(:schedule, minute: 3))
    end
    it 'detect includes even on association proxy' do
      person = create(:schedule).person
      expect(person.reload.schedules).to include(build(:schedule))
    end
  end
end
