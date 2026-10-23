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
    # `count` schedules of 30 minutes each, consecutive starting at 13:00 on
    # the given day - i.e. one real meeting-length run, not scattered slots
    def consecutive_slots(factory, day:, count:, start_hour: 13)
      create(factory).tap do |person|
        count.times do |i|
          create(:schedule, person: person, day: day, hour: start_hour + (i / 2), minute: (i % 2) * 30)
        end
      end
    end

    # several isolated single slots, each at least an hour apart from the
    # next so none of them are consecutive with another
    def scattered_slots(factory, count)
      create(factory).tap do |person|
        count.times { |i| create(:schedule, person: person, day: 1 + (i / 5), hour: 13 + (i % 5), minute: 0) }
      end
    end

    shared_examples 'availability' do |factory|
      let!(:none) { create(factory) }
      let!(:scattered) { scattered_slots(factory, 7) }
      let!(:leftover_after_one_window) { consecutive_slots(factory, day: 1, count: 4) }
      let!(:one_window) { consecutive_slots(factory, day: 1, count: 3) }
      let!(:two_windows_one_run) { consecutive_slots(factory, day: 1, count: 6) }
      let!(:two_windows_two_days) do
        create(factory).tap do |person|
          [1, 2].each do |day|
            3.times { |i| create(:schedule, person: person, day: day, hour: 13 + (i / 2), minute: (i % 2) * 30) }
          end
        end
      end
      let!(:three_windows) { consecutive_slots(factory, day: 1, count: 9) }
      let(:klass) { none.class }

      it 'classifies by the number of complete, consecutive 1.5 hour windows' do
        people = [none, scattered, leftover_after_one_window, one_window,
                  two_windows_one_run, two_windows_two_days, three_windows]
        expect(people.map { |p| described_class.availability_status(p) })
          .to eq(%i[none none partial partial partial partial full])
      end

      it 'filters a relation by status' do
        expect(described_class.filter_by_availability(klass.all, 'none')).to contain_exactly(none, scattered)
        expect(described_class.filter_by_availability(klass.all, 'partial'))
          .to contain_exactly(leftover_after_one_window, one_window, two_windows_one_run, two_windows_two_days)
        expect(described_class.filter_by_availability(klass.all, 'full')).to contain_exactly(three_windows)
        expect(described_class.filter_by_availability(klass.all, '')).to include(none, three_windows)
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
