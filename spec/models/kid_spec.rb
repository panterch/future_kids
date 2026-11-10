# frozen_string_literal: true

require 'spec_helper'

describe Kid do
  let(:monday) { Time.zone.parse('2011-01-03 22:00') }
  let(:thursday) { Time.zone.parse('2011-01-06 22:00') }
  let(:friday) { Time.zone.parse('2011-01-07 22:00') }

  context 'dates' do
    subject { build(:kid) }

    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:dob) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:dob) }
    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:exit_at) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:exit_at) }
    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:checked_at) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:checked_at) }
    it { is_expected.to allow_values(Date.parse('2021-11-18')).for(:coached_at) }
    it { is_expected.not_to allow_values(Date.parse('0021-11-18')).for(:coached_at) }
  end

  context 'embedded journals' do
    let(:kid) { create(:kid) }
    let(:mentor) { create(:mentor) }

    it 'can associate a journal' do
      attrs = attributes_for(:journal)
      attrs[:mentor_id] = mentor.id
      kid.journals.create!(attrs)
      expect(described_class.find(kid.id).journals.size).to eq(1)
    end

    it 'can populate journal via nested attributes' do
      kid.update(journals_attributes: [{ 'mentor_id' => mentor.id }])
      expect(kid.journals.size).to eq(1)
    end

    it 'does sort journal correctly' do
      old_record =      create(:journal, held_at: Date.parse('2010-01-01'), kid: kid)
      recent_record =   create(:journal, held_at: Date.parse('2020-01-01'), kid: kid)
      very_old_record = create(:journal, held_at: Date.parse('2002-01-01'), kid: kid)
      expect(kid.journals.map(&:held_at)).to eq(
        [recent_record, old_record, very_old_record].map(&:held_at)
      )
    end

    it 'cleans up journals on deletion' do
      journal = create(:journal, kid: kid)
      kid.destroy
      expect(Journal).not_to exist(journal.id)
      expect(described_class).not_to exist(kid.id)
    end
  end

  context 'goals' do
    let(:kid) { build(:kid) }

    it 'validates on factory values' do
      expect(kid).to be_valid
    end

    it 'does not require the free-text goals at all' do
      kid.goal_1 = ''
      kid.goal_2 = ''
      expect(kid).to be_valid
    end

    Kid::GOAL_CARDS.each do |key, card|
      context "the #{key} card" do
        it 'is invalid with none of its goals checked' do
          card[:goals].each { |g| kid[g] = false }
          expect(kid).not_to be_valid
          expect(kid.errors[:"goal_card_#{key}"])
            .to include("Bitte geben Sie mindestens einen Förderbereich bei #{card[:label]} an")
        end

        it "is valid with exactly #{card[:max]} (its max) checked" do
          card[:goals].first(card[:max]).each { |g| kid[g] = true }
          expect(kid).to be_valid
        end

        it 'is invalid with one more than its max checked' do
          card[:goals].first(card[:max] + 1).each { |g| kid[g] = true }
          expect(kid).not_to be_valid
          expect(kid.errors[:"goal_card_#{key}"])
            .to include("Bitte geben Sie maximal #{card[:max]} Förderbereiche bei #{card[:label]} an")
        end
      end
    end

    # most existing kids predate the min/max-per-card rule and don't satisfy
    # it - update_columns bypasses validation to build that state, exactly
    # like the real legacy data in the database
    context 'a persisted kid whose goals predate this rule' do
      let(:kid) do
        create(:kid).tap do |k|
          k.update_columns(goal_3: nil, goal_16: nil, goal_25: nil, goal_32: nil) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      it 'stays valid, and saveable, as long as nothing in its goals changes' do
        expect(kid.reload).to be_valid
        expect(kid.update(note: 'changed')).to be(true)
      end

      it "re-enforces a card's rule, but only that card, once it's actually touched" do
        kid.goal_3 = true # deutsch: nil -> true, a genuine touch, now satisfies its min of 1
        expect(kid).to be_valid
        expect(kid.errors[:goal_card_mathematik]).to be_empty # untouched, stays skipped
      end

      it 'fails once a genuinely touched card is left empty' do
        other = create(:kid) # goal_16 is true here (factory default)
        other.goal_16 = false # mathematik: true -> false, a genuine touch, now empty
        expect(other).not_to be_valid
        expect(other.errors[:goal_card_mathematik])
          .to include('Bitte geben Sie mindestens einen Förderbereich bei Mathematik an')
      end

      it 'does not treat an unchecked checkbox resubmitting false as a touch' do
        kid.goal_3 = false # nil -> false: the same falsy state an untouched form resubmits
        expect(kid).to be_valid
      end
    end

    it 'does not let a different card compensate for an empty one' do
      kid.goal_3 = false # empties the deutsch card set up by the factory
      expect(kid).not_to be_valid
      expect(kid.errors[:goal_card_deutsch]).to be_present
      expect(kid.errors[:goal_card_mathematik]).to be_empty
    end

    it 'tracks changes in goals' do
      last_updated = Time.zone.now
      kid.goal_1 = 'test'
      kid.save!
      expect(kid.goals_updated_at).to be > last_updated

      kid.goals_updated_at
      kid.goal_4 = true
      kid.save!
      expect(kid.goals_updated_at).to be > last_updated

      kid.goals_updated_at
      kid.name = 'changed'
      kid.save!
      expect(kid.goals_updated_at.utc.to_s).to eq last_updated.utc.to_s
    end
  end

  context 'relation to mentor' do
    let(:kid) { build(:kid) }

    it 'does associate a mentor' do
      kid.mentor = create(:mentor)
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
    end

    it 'sets mentor via mentor_id' do
      kid.mentor_id = create(:mentor).id
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
    end

    it 'does associate a secondary mentor' do
      kid.secondary_mentor_id = create(:mentor).id
      kid.save! && kid.reload
      expect(kid.secondary_mentor).to be_present
    end

    it 'can associate both mentors' do
      kid.mentor = create(:mentor)
      kid.secondary_mentor = create(:mentor)
      kid.save! && kid.reload
      expect(kid.mentor).to be_present
      expect(kid.secondary_mentor).to be_present
      expect(kid.mentor).not_to eql(kid.secondary_mentor)
    end

    it 'can be called via secondary_kid accessor' do
      kid.secondary_mentor = mentor = create(:mentor)
      kid.save! && kid.reload && mentor.reload
      expect(mentor.secondary_kids.first).to eq(kid)
    end

    it 'does sync its school with the mentors school through association' do
      kid.school = create(:school)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.school_id).to eq mentor.reload.kids.last.school_id
      expect(kid.school.display_name).to eq mentor.reload.kids.last.school.display_name
      kid.school = nil
      kid.save!
      expect(mentor.reload.kids.last.school).to be_nil
    end

    it 'does sync its coach with the mentors coach through association' do
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.admin_id).to eq mentor.reload.kids.last.admin_id
      expect(kid.admin.display_name).to eq mentor.reload.kids.last.admin.display_name
      kid.admin = nil
      kid.save!
      expect(mentor.reload.kids.last.admin).to be_nil
    end

    it 'does sync its meeting day with mentor' do
      kid = create(:kid, meeting_day: '1')
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(kid.meeting_day).to eq(mentor.reload.kids.last.meeting_day)
      kid.meeting_day = nil
      kid.save!
      expect(mentor.reload.kids.last.meeting_day).to be_nil
    end

    it 'does release synced relations on mentors when inactivated' do
      kid.school = create(:school)
      kid.admin = create(:admin)
      kid.mentor = mentor = create(:mentor)
      kid.save!
      expect(mentor.reload.kids.last.school).to be_truthy
      expect(mentor.reload.kids.last.admin).to be_truthy
      kid.inactive = true
      kid.save!
      expect(mentor.reload.kids).to be_empty
      expect(mentor.reload.schools.count).to eq(0)
      expect(mentor.reload.admins.count).to eq(0)
    end

    it 'does nilify mentors when set inactive' do
      kid.mentor = create(:mentor)
      kid.secondary_mentor = create(:mentor)
      kid.admin = create(:admin)
      kid.save!

      k = described_class.find(kid.id)
      k.inactive = true
      k.save!

      k = described_class.find(k.id)
      expect(k.mentor).to be_nil
      expect(k.secondary_mentor).to be_nil
      expect(k.admin).to be_nil
    end
  end

  context 'relation to admin' do
    let(:kid) { build(:kid) }

    it 'does associate a mentor' do
      admin = kid.admin = create(:admin)
      kid.save! && kid.reload
      expect(kid.admin).to be_present
      expect(kid.admin).to eq(admin)
    end
  end

  context 'specific updated_at fields' do
    let(:kid) { create(:kid) }
    let!(:time) { Time.zone.now }

    it 'tracks schedulue updates' do
      expect(kid.schedules_updated_at).to be_nil
      kid.schedules.create!(day: 1, hour: 13, minute: 0)
      expect(kid.schedules_updated_at).to be > time
    end
  end

  context 'meeting time calculation' do
    before do
      @kid = create(:kid, meeting_day: 3,
                          meeting_start_at: Time.zone.parse('18:00'))
    end

    it 'returns saturday evening when not enough information' do
      @kid.meeting_day = nil
      meeting = @kid.calculate_meeting_time(thursday)
      expect(meeting).to eq(Time.zone.parse('2011-01-08 18:00'))
    end

    it 'calculates the correct meeting time in past' do
      meeting = @kid.calculate_meeting_time(thursday)
      expect(meeting).to eq(Time.zone.parse('2011-01-05 18:00'))
    end

    it 'calculates the correct meeting time in future' do
      meeting = @kid.calculate_meeting_time(monday)
      expect(meeting).to eq(Time.zone.parse('2011-01-05 18:00'))
    end

    it 'has no journal entry due at monday' do
      expect(@kid).not_to be_journal_entry_due(monday)
    end

    it 'has journal entry due at friday' do
      expect(@kid).to be_journal_entry_due(friday)
    end
  end

  context 'journal entry for week' do
    before do
      @kid = create(:kid, meeting_day: 2, meeting_start_at: '13:00')
      @journal = create(:journal, kid: @kid, held_at: thursday)
    end

    it 'finds journal entry in future' do
      expect(@kid.journal_entry_for_week(monday)).to eq(@journal)
    end

    it 'finds journal entry in past' do
      expect(@kid.journal_entry_for_week(friday)).to eq(@journal)
    end

    it 'detects missing journal entries' do
      @journal.destroy
      expect(@kid.journal_entry_for_week(friday)).to be_nil
    end
  end

  context 'journal statistics' do
    let(:mentor) { create(:mentor) }
    let(:kid) { create(:kid, mentor: mentor) }

    def journal(held_at, cancelled: false, mentor: self.mentor, minutes: 60)
      if cancelled
        create(:cancelled_journal, kid: kid, mentor: mentor, held_at: held_at)
      else
        create(:journal, kid: kid, mentor: mentor, held_at: held_at,
                         start_at: Time.zone.parse('13:00'), end_at: Time.zone.parse('13:00') + minutes.minutes)
      end
    end

    it 'splits the journals at the start of the recent period, oldest first' do
      since = described_class.recent_since
      later = journal(since + 1.week)
      older = journal(since - 1.day)
      first_recent = journal(since)
      expect(kid.recent_journals).to eq([first_recent, later])
      expect(kid.earlier_journals).to eq([older])
    end

    it 'starts the recent period two months before the given date' do
      expect(described_class.recent_since(Date.new(2026, 12, 1))).to eq(Date.new(2026, 10, 1))
    end

    it 'counts cancelled journals, of all journals or of the given ones' do
      journal(Date.new(2024, 3, 1), cancelled: true)
      journal(Date.new(2024, 3, 8))
      last = journal(Date.new(2024, 3, 15), cancelled: true)
      expect(kid.journals_cancelled_count).to eq(2)
      expect(kid.journals_cancelled_count([last])).to eq(1)
    end

    it 'averages the duration of the held journals only' do
      entries = [journal(Date.new(2024, 3, 1), minutes: 60), journal(Date.new(2024, 3, 8), minutes: 90),
                 journal(Date.new(2024, 3, 15), cancelled: true)]
      expect(kid.journals_average_duration(entries)).to eq(75.0)
    end

    it 'has no average duration without held journals' do
      expect(kid.journals_average_duration([journal(Date.new(2024, 3, 1), cancelled: true)])).to be_nil
    end

    it 'finds the longest gap in days between two held journals, ignoring cancelled ones' do
      journal(Date.new(2024, 3, 1))
      journal(Date.new(2024, 3, 8), cancelled: true)
      journal(Date.new(2024, 3, 15))
      journal(Date.new(2024, 3, 20))
      expect(kid.longest_journal_gap_days).to eq(14)
    end

    it 'has no longest gap with fewer than two held journals' do
      journal(Date.new(2024, 3, 1))
      journal(Date.new(2024, 3, 8), cancelled: true)
      expect(kid.longest_journal_gap_days).to be_nil
    end

    context 'mentor changes' do
      let(:other_mentor) { create(:mentor) }

      it 'has none while the same mentor writes all journals' do
        journal(Date.new(2024, 3, 1))
        journal(Date.new(2024, 3, 8))
        expect(kid.mentor_change_dates).to eq([])
      end

      it 'dates a change at the first journal of a further mentor' do
        journal(Date.new(2024, 3, 1))
        journal(Date.new(2024, 3, 8))
        journal(Date.new(2024, 9, 2), mentor: other_mentor)
        journal(Date.new(2024, 9, 9), mentor: other_mentor)
        expect(kid.mentor_change_dates).to eq([Date.new(2024, 9, 2)])
      end

      it 'counts a second mentor once, at their first journal, however often the mentors alternate' do
        journal(Date.new(2024, 3, 1))
        journal(Date.new(2024, 3, 8), mentor: other_mentor)
        journal(Date.new(2024, 3, 15))
        journal(Date.new(2024, 3, 22), mentor: other_mentor)
        expect(kid.mentor_change_dates).to eq([Date.new(2024, 3, 8)])
      end

      it 'ignores mentor assignments in the relation log that never wrote a journal' do
        journal(Date.new(2024, 3, 1))
        kid.update!(mentor: other_mentor)
        kid.update!(mentor: mentor)
        expect(kid.relation_logs.count).to be > 1
        expect(kid.mentor_change_dates).to eq([])
      end
    end
  end

  describe '#ai_review_due?' do
    let(:kid) { create(:kid, mentor: create(:mentor)) }

    it 'is due when never reviewed and journals exist' do
      create(:journal, kid: kid)
      expect(kid).to be_ai_review_due
    end

    it 'is not due when never reviewed and there are no journals' do
      expect(kid).not_to be_ai_review_due
    end

    it 'is due when a journal was created after the last review' do
      create(:journal, kid: kid)
      kid.update!(ai_review_generated_at: 1.hour.ago)
      expect(kid).to be_ai_review_due
    end

    it 'is not due without a journal created since the last review' do
      create(:journal, kid: kid)
      kid.update!(ai_review_generated_at: 1.hour.from_now)
      expect(kid).not_to be_ai_review_due
    end
  end

  describe '#human_ai_review' do
    let(:kid) { build(:kid) }

    it 'renders the markdown answer, headings and emphasis, as HTML' do
      kid.ai_review = "## Zusammenfassung\n\n**Wichtig:** grosse Fortschritte"
      expect(kid.human_ai_review).to include('<h2>Zusammenfassung</h2>', '<strong>Wichtig:</strong>')
    end

    it 'keeps gender stars as they are instead of turning them into emphasis' do
      kid.ai_review = 'Sara und ihre Mentor*innen besprachen mit den Lehrer*innen die **Ziele**.'
      html = kid.human_ai_review
      expect(html).to include('Mentor*innen besprachen mit den Lehrer*innen', '<strong>Ziele</strong>')
      expect(html).not_to include('<em>')
    end

    it 'escapes raw HTML in the AI response instead of passing it through' do
      kid.ai_review = '<script>alert(1)</script>'
      expect(kid.human_ai_review).not_to include('<script>')
      expect(kid.human_ai_review).to include('&lt;script&gt;')
    end

    it 'returns nil when there is no review' do
      expect(kid.human_ai_review).to be_nil
    end
  end

  context 'association with admin, mentor and school' do
    it { is_expected.to belong_to(:admin).optional }

    it { is_expected.to belong_to(:mentor).optional }

    it { is_expected.to belong_to(:school).optional }
  end
end
