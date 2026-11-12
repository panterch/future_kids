# frozen_string_literal: true

class Kid < ApplicationRecord
  default_scope { order(:name, :prename) }

  # filter of the kids index
  filter_scope :filter_by_availability, ->(status) { Schedule.filter_by_availability(all, status) }

  scope :active, -> { where(inactive: false) }
  scope :with_mentor, -> { where.not(mentor_id: nil) }

  belongs_to :mentor, optional: true
  belongs_to :secondary_mentor, class_name: 'Mentor', optional: true
  belongs_to :teacher, optional: true
  belongs_to :secondary_teacher, class_name: 'Teacher', optional: true
  belongs_to :third_teacher, class_name: 'Teacher', optional: true
  belongs_to :admin, optional: true
  belongs_to :school, optional: true

  has_many :journals, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :first_year_assessments, dependent: :destroy
  has_many :termination_assessments, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :schedules, as: :person, dependent: :destroy
  has_many :relation_logs, dependent: :nullify
  GOALS_1 = %i[goal_3 goal_4 goal_5 goal_6 goal_7
               goal_8 goal_9 goal_10 goal_11 goal_12 goal_13 goal_14
               goal_15 goal_16 goal_17 goal_18 goal_19 goal_20 goal_21
               goal_22 goal_23 goal_24].freeze
  GOALS_1_MAX = 4

  GOALS_2 = %i[goal_25 goal_26 goal_27 goal_28 goal_29 goal_30 goal_31
               goal_32 goal_33 goal_34 goal_35].freeze
  GOALS_2_MAX = 2

  # the recent part of a kid's profile (kids/show.md.erb): the journal
  # statistics compare it with the time before, and the timeline lists it as a
  # section of its own ("Aktueller Verlauf") for the AI review's "Aktuelle
  # Entwicklungen". Texts show its start date rather than its length, so
  # changing it needs no text changes
  RECENT_PERIOD = 2.months

  accepts_nested_attributes_for :journals, :reviews, :schedules

  validates :name, :prename, presence: true

  validates :meeting_day, numericality: { only_integer: true, allow_blank: true,
                                          greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validates :dob, :exit_at, :checked_at, :coached_at,
            comparison: { greater_than_or_equal_to: MIN_DATE }, allow_blank: true

  # validate that enough goals were given in each group. The maximum per group
  # (GOALS_1_MAX, GOALS_2_MAX) is only a hint in the form and is not enforced
  validate do |kid|
    goals_1_count = GOALS_1.count { |g| kid[g].present? }
    if kid[:goal_1].blank? && goals_1_count.zero?
      GOALS_1.each { |g| errors.add g, :invalid, message: '' }
      errors.add :goal_1, :invalid, message: 'Bitte geben Sie mindestens einen fachlichen Förderbereich an'
    end

    goals_2_count = GOALS_2.count { |g| kid[g].present? }
    if kid[:goal_2].blank? && goals_2_count.zero?
      GOALS_2.each { |g| errors.add g, :invalid, message: '' }
      errors.add :goal_2, :invalid, message: 'Bitte geben Sie mindestens einen überfachlichen Förderbereich an'
    end
  end

  after_validation :track_goal_updates
  before_destroy :release_relations
  after_save :release_relations, if: :inactive?
  after_save :track_relations

  # takes the given time argument (or Time.now) and calculates the
  # date and time for that weeks meeting
  def calculate_meeting_time(time = Time.zone.now)
    meeting_day = self.meeting_day
    meeting_start_at = self.meeting_start_at

    if meeting_day.blank? || meeting_start_at.blank?
      # saturday evening
      meeting_day = 6
      meeting_start_at = Time.zone.parse('18:00')
    end
    time = time.monday
    time += (meeting_day - 1).days
    time += meeting_start_at.hour.hours
    time += meeting_start_at.min.minutes
    time
  end

  # tries to retrieve the journal entry for the week given by time
  def journal_entry_for_week(time = Time.zone.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?

    journals.find_by(week: time.strftime('%U').to_i, year: time.year)
  end

  # tries to retrieve the reminder for the week given by time
  def reminder_entry_for_week(time = Time.zone.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?

    reminders.find_by(week: time.strftime('%U').to_i, year: time.year)
  end

  # checks wether a journal entry is already due for the week given by time
  def journal_entry_due?(time = Time.zone.now)
    meeting_time = calculate_meeting_time(time)
    return false if meeting_time.nil?

    (meeting_time + 1.day) < time
  end

  # true if a journal was created after the last AI review (KidAiReviewer), or
  # if the kid has journals but was never reviewed
  def ai_review_due?
    last_journal_at = journals.maximum(:created_at)
    last_journal_at.present? && (ai_review_generated_at.nil? || last_journal_at > ai_review_generated_at)
  end

  # journal statistics for kids/show.md.erb (and so for KidAiReviewer):
  # plain numbers and dates, the wording lives in the template

  def self.recent_since(date = Date.current)
    date - RECENT_PERIOD
  end

  def recent_journals
    journals.where(held_at: Kid.recent_since..).reorder(held_at: :asc, id: :asc).to_a
  end

  def earlier_journals
    journals.where(held_at: ...Kid.recent_since).reorder(held_at: :asc, id: :asc).to_a
  end

  def journals_cancelled_count(entries = journals)
    entries.count(&:cancelled?)
  end

  # nil when there are no held (non-cancelled) journals among the entries
  def journals_average_duration(entries)
    held = entries.reject(&:cancelled?)
    return nil if held.empty?

    held.sum(&:duration).to_f / held.size
  end

  # nil when there are fewer than two held journals to compare
  def longest_journal_gap_days
    dates = journals.reject(&:cancelled?).map(&:held_at).sort
    return nil if dates.size < 2

    dates.each_cons(2).map { |a, b| (b - a).to_i }.max
  end

  # dates of the actual mentor changes: the first journal of each further
  # mentor. Derived from who wrote the journals, not from RelationLog, which
  # also holds administrative corrections that never were a real change. Each
  # further mentor counts once - a secondary mentor too, at their first
  # journal - however often mentors alternate afterwards (journals.mentor_id
  # is NOT NULL)
  def mentor_change_dates
    journals.reorder(nil).group(:mentor_id).minimum(:held_at).values.sort.drop(1)
  end

  # shows when last schedule relation entry was edited
  def schedules_updated_at
    Schedule.schedules_updated_at(self)
  end

  def display_name
    return 'Neuer Eintrag' if new_record?

    [name, prename].compact_blank.join(', ')
  end

  enum :exit_kind, { exit: 'exit', later: 'later', continue_term: 'continue_term', continue: 'continue' },
       validate: { allow_nil: true }
  enum :sex, { male: 'm', female: 'f', diverse: 'd' }
  human_text_attributes :goal, :goal_1, :goal_2, :simplified_schedule, :note, :todo
  human_time_attributes :meeting_start_at
  human_rails_enum_attributes :exit_kind, :sex

  def human_meeting_day
    return nil if meeting_day.nil?

    I18n.t('date.day_names')[meeting_day]
  end

  def parent_country_name
    return '' if parent_country.blank?

    c = ISO3166::Country[parent_country]
    c.translations[I18n.locale.to_s] || c.name
  end

  # the AI review is markdown (section headings, lists, emphasis), so it is
  # rendered with Redcarpet rather than TextFormatter (which deliberately
  # isn't markdown). no_intra_emphasis keeps gender stars ("Mentor*innen",
  # copied from the journals) from turning the text between them into
  # emphasis. it comes from a third-party AI response, so raw HTML is escaped
  # rather than passed through
  def human_ai_review
    return if ai_review.nil?

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true), no_intra_emphasis: true
    )
    markdown.render(ai_review).html_safe # rubocop:disable Rails/OutputSafety
  end

  protected

  def release_relations
    # Use update_columns to bypass callbacks and directly update the database
    # This prevents infinite loops since we're in an after_save callback
    update_columns( # rubocop:disable Rails/SkipsModelValidations
      mentor_id: nil,
      secondary_mentor_id: nil,
      teacher_id: nil,
      secondary_teacher_id: nil,
      third_teacher_id: nil,
      admin_id: nil
    )
  end

  def track_relations
    track_relation(:mentor)
    track_relation(:secondary_mentor)
    track_relation(:teacher)
    track_relation(:secondary_teacher)
    track_relation(:third_teacher)
    track_relation(:admin)
  end

  # create a relation log for the given field if it has changed
  def track_relation(field)
    changed = saved_change_to_attribute?("#{field}_id")
    current_id = send("#{field}_id")
    previous_id = attribute_before_last_save("#{field}_id")
    if changed && previous_id
      relation_logs.create!(user_id: previous_id,
                            role: field,
                            end_at: Time.zone.now)
    end
    return unless changed && current_id

    relation_logs.create!(user_id: send("#{field}_id"),
                          role: field,
                          start_at: Time.zone.now)
  end

  # track all changes of the goal freetext and checkbox fields
  # in one field
  def track_goal_updates
    return unless changed.any? { |k| k.start_with?('goal_') }

    self.goals_updated_at = Time.zone.now
  end
end
