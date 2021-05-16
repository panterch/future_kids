class Kid < ApplicationRecord
  include ActionView::Helpers::TextHelper, HasCoordinates

  default_scope { order(:name, :prename) }

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
  has_many :substitutions, dependent: :destroy
  has_many :relation_logs, dependent: :nullify

  accepts_nested_attributes_for :journals, :reviews, :schedules

  validates_presence_of :name, :prename

  validates_numericality_of :meeting_day, only_integer: true, allow_blank: true,
                                          greater_than_or_equal_to: 1, less_than_or_equal_to: 5

  after_save :track_relations
  after_validation :track_specific_field_updates
  after_validation :release_relations, if: :inactive?
  before_destroy :release_relations


  # takes the given time argument (or Time.now) and calculates the
  # date and time for that weeks meeting
  def calculate_meeting_time(time = Time.now)
    return nil if meeting_day.blank? || meeting_start_at.blank?
    time = time.monday
    time += (meeting_day - 1).days
    time += meeting_start_at.hour.hours
    time += meeting_start_at.min.minutes
    time
  end

  # tries to retrieve the journal entry for the week given by time
  def journal_entry_for_week(time = Time.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?
    journals.find_by(week: time.strftime('%U').to_i, year: time.year)
  end

  # tries to retrieve the reminder for the week given by time
  def reminder_entry_for_week(time = Time.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?
    reminders.find_by(week: time.strftime('%U').to_i, year: time.year)
  end

  # checks wether a journal entry is already due for the week given by time
  def journal_entry_due?(time = Time.now)
    meeting_time = calculate_meeting_time(time)
    return false if meeting_time.nil?
    (meeting_time + 1.day) < time
  end

  # when controlling reminders it is useful to know the date of the most recent
  # journal entry made for the associated kid
  def last_journal_entry
    journals.order('held_at DESC').first
  end

  # shows when last schedule relation entry was edited
  def schedules_updated_at
    Schedule.schedules_updated_at(self)
  end

  def display_name
    return 'Neuer Eintrag' if new_record?
    [name, prename].reject(&:blank?).join(' ')
  end

  def human_goal
    text_format(goal)
  end

  def human_goal_1
    text_format(goal_1)
  end

  def human_goal_2
    text_format(goal_2)
  end

  def human_note
    text_format(note)
  end

  def human_todo
    text_format(todo)
  end

  def human_abnormality
    text_format(abnormality)
  end

  def human_abnormality_criticality
    return '' unless abnormality_criticality
    I18n.t(abnormality_criticality, scope: 'kids.criticality')
  end

  def human_sex
    { 'm' => '♂', 'f' => '♀' }[sex]
  end

  def human_meeting_day
    return nil if meeting_day.nil?
    I18n.t('date.day_names')[meeting_day]
  end

  def human_meeting_start_at
    return nil if meeting_start_at.nil?
    I18n.l(meeting_start_at, format: :time)
  end

  def human_exit_kind
    return '' if exit_kind.blank?
    I18n.t(exit_kind, scope: 'exit_kind')
  end

  def parent_country_name
    return '' if parent_country.blank?
    c = ISO3166::Country[self.parent_country]
    return c.translations[I18n.locale.to_s] || c.name
  end

protected

  def release_relations
    self.mentor = nil
    self.secondary_mentor = nil
    self.teacher = nil
    self.secondary_teacher = nil
    self.third_teacher = nil
    self.admin = nil
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
                            end_at: Time.now)
    end
    if changed && current_id
      relation_logs.create!(user_id: send("#{field}_id"),
                            role: field,
                            start_at: Time.now)
    end
  end

  # some fields are tracked specifically for updates
  # contract is to track field changes in a field
  # named the same with a suffix updated_at
  def track_specific_field_updates
    self.goal_1_updated_at = Time.now if goal_1_changed?
    self.goal_2_updated_at = Time.now if goal_2_changed?
  end
end
