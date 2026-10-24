# frozen_string_literal: true

class Kid < ApplicationRecord
  default_scope { order(:name, :prename) }

  # Filters kids by availability status. Used only in the kid index form.
  attr_accessor :filter_by_availability

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
  # The goal checkboxes (see KidsHelper::SUBJECT_GOAL_CARDS/GENERAL_GOAL_CARDS
  # for their sub-group display layout), grouped exactly as shown on the kid
  # form's four cards. Each card independently requires at least one and at
  # most :max checked goals - see the validation below; :label names the
  # card in both the form and the validation messages.
  GOAL_CARDS = {
    deutsch: { label: 'Deutsch',
               goals: %i[goal_3 goal_4 goal_5 goal_6 goal_7 goal_8 goal_9
                         goal_10 goal_11 goal_12 goal_13 goal_14 goal_15], max: 4 },
    mathematik: { label: 'Mathematik',
                  goals: %i[goal_16 goal_17 goal_18 goal_19 goal_20 goal_21
                            goal_22 goal_23 goal_24], max: 4 },
    personale: { label: 'Personale Förderbereiche',
                 goals: %i[goal_25 goal_26 goal_27 goal_28 goal_29 goal_30 goal_31], max: 2 },
    methodische: { label: 'Methodische Förderbereiche',
                   goals: %i[goal_32 goal_33 goal_34 goal_35], max: 2 }
  }.freeze

  accepts_nested_attributes_for :journals, :reviews, :schedules

  validates :name, :prename, presence: true

  validates :meeting_day, numericality: { only_integer: true, allow_blank: true,
                                          greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validates :dob, :exit_at, :checked_at, :coached_at,
            comparison: { greater_than_or_equal_to: MIN_DATE }, allow_blank: true

  # each of the four goal cards independently needs at least one and allows
  # at most :max checked goals; the free-text "Ergänzungen" fields (goal_1,
  # goal_2) are plain supplementary text and play no part in this
  # validation. The error is added on a synthetic :goal_card_<key> attribute
  # (not a real column) so kids/_form can show it next to the right card.
  validate do |kid|
    GOAL_CARDS.each do |key, card|
      count = card[:goals].count { |g| kid[g].present? }
      next if count.between?(1, card[:max])

      card[:goals].each { |g| errors.add g, :invalid, message: '' }
      message = if count.zero?
                  "Bitte geben Sie mindestens einen Förderbereich bei #{card[:label]} an"
                else
                  "Bitte geben Sie maximal #{card[:max]} Förderbereiche bei #{card[:label]} an"
                end
      errors.add :"goal_card_#{key}", :invalid, message: message
    end
  end

  # errors.add reads the current value of the attribute it's attached to;
  # goal_card_* (see above) isn't a real column/method, so without this it
  # would raise instead of just leaving the error's value blank
  def read_attribute_for_validation(key)
    return nil if key.to_s.start_with?('goal_card_')

    super
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

  # when controlling reminders it is useful to know the date of the most recent
  # journal entry made for the associated kid
  def last_journal_entry
    journals.order(held_at: :desc).first
  end

  # true if journal entries were added or edited after the summary was generated,
  # or if no summary has been generated yet while entries exist
  def journal_summary_stale?
    return false unless journals.exists?
    return true if journal_summary_generated_at.blank?

    journals.maximum(:updated_at) > journal_summary_generated_at
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

  # the AI summary may contain markdown (e.g. emphasis) despite the prompt
  # asking for plain flowing text, so it is rendered like
  # Site#terms_of_use_html rather than through simple_format. it comes from a
  # third-party AI response, so raw HTML is escaped rather than passed through
  def human_journal_summary
    return unless journal_summary

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true), autolink: true, tables: true
    )
    markdown.render(journal_summary).html_safe # rubocop:disable Rails/OutputSafety
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
