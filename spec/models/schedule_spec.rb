# frozen_string_literal: true

require 'spec_helper'

describe Schedule do
  let(:kid) { create(:kid) }
  let(:mentor) { create(:mentor) }

  it 'belongs to a mentor' do
    mentor.schedules.create!(day: 1, hour: 13, minute: 0)
    expect(mentor.reload.schedules).not_to be_empty
  end

  it 'belongs to a kid' do
    kid.schedules.create!(day: 1, hour: 13, minute: 0)
    expect(kid.reload.schedules).not_to be_empty
  end

  it 'doeses not create the same entry twice' do
    mentor.schedules.create!(day: 1, hour: 13, minute: 0)
    expect { mentor.schedules.create!(day: 1, hour: 13, minute: 0) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'builds schedules for a whole week' do
    week = described_class.build_week
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

  describe 'availability' do
    def person_with_slots(factory, count)
      create(factory).tap do |person|
        count.times { |i| create(:schedule, person: person, day: 1 + (i / 10), hour: 13 + (i % 10), minute: 0) }
      end
    end

    shared_examples 'availability' do |factory|
      let!(:none)   { person_with_slots(factory, 0) }
      let!(:one)    { person_with_slots(factory, 1) }
      let!(:window) { person_with_slots(factory, 3) }
      let!(:six)    { person_with_slots(factory, 6) }
      let!(:seven)  { person_with_slots(factory, 7) }
      let(:klass)   { none.class }

      it 'classifies by number of 30 minute slots' do
        expect([none, one, window, six, seven].map { |p| described_class.availability_status(p) })
          .to eq(%i[none partial partial partial full])
      end

      it 'filters a relation by status' do
        expect(described_class.filter_by_availability(klass.all, 'none')).to contain_exactly(none)
        expect(described_class.filter_by_availability(klass.all, 'partial')).to contain_exactly(one, window, six)
        expect(described_class.filter_by_availability(klass.all, 'full')).to contain_exactly(seven)
        expect(described_class.filter_by_availability(klass.all, '')).to include(none, seven)
      end
    end

    describe 'for kids' do
      it_behaves_like 'availability', :kid
    end

    describe 'for mentors' do
      it_behaves_like 'availability', :mentor
    end
  end
end
