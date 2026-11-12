# frozen_string_literal: true

class Mentor < User
  # filters of the mentors index: by their kids' coach, meeting day and
  # school, and by the mentors' availability
  filter_scope :filter_by_coach_id, ->(id) { joins(:admins).where(kids: { admin_id: id.to_i }).distinct }
  filter_scope :filter_by_meeting_day, ->(day) { joins(:kids).where(kids: { meeting_day: day.to_i }).distinct }
  filter_scope :filter_by_school_id, ->(id) { joins(:kids).where(kids: { school_id: id.to_i }).distinct }
  filter_scope :filter_by_availability, ->(status) { Schedule.filter_by_availability(all, status) }

  has_many :kids, dependent: :nullify
  has_many :admins, through: :kids
  has_many :secondary_kids, class_name: 'Kid',
                            foreign_key: 'secondary_mentor_id', inverse_of: :secondary_mentor,
                            dependent: :nullify
  has_many :journals, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :secondary_reminders, class_name: 'Reminder',
                                 foreign_key: 'secondary_mentor_id', inverse_of: :secondary_mentor,
                                 dependent: :nullify
  has_many :schedules, as: :person, inverse_of: :person, dependent: :destroy

  belongs_to :school, optional: true

  enum :ects, { currently: 1, alumni: 2, employed: 3 }

  # Unscope is needed because the association is done through kids.
  # Kids are ordered so distinct was looking at the kids scope in order to
  # produce distinct results. Unscoping order enables distinct to remove duplicates.
  has_many :schools, -> { unscope(:order).distinct }, through: :kids

  accepts_nested_attributes_for :schedules

  after_validation :track_exit_kind_updates
  after_save :release_relations, if: :inactive?

  # the html5 date submit allows two letter dates (e.g. '21') and translates them to wrong years (like '0021')
  validates :exit_at, comparison: { greater_than_or_equal_to: MIN_DATE }, allow_blank: true
  validates :dob, comparison: { greater_than: Date.new(1900, 1, 1) }, allow_blank: true

  def total_duration
    journals.sum(:duration)
  end

  def total_duration_last_month_with_coaching
    last_month = Time.zone.today - 1.month
    journals = self.journals.where(year: last_month.year, month: last_month.month).to_a
    journals << Journal.coaching_entry(self, last_month.month, last_month.year)
    journals.sum(&:duration)
  end

  def month_count
    Journal.unscoped.where(mentor_id: id).select('DISTINCT (month, year)').count
  end

  human_rails_enum_attributes :exit_kind, :ects

  # shows when last schedule relation entry was edited
  def schedules_updated_at
    Schedule.schedules_updated_at(self)
  end

  protected

  # inactive mentors should not be connected to other persons
  def release_relations
    kids.clear
    secondary_kids.clear
  end

  def track_exit_kind_updates
    return unless exit_kind_changed?

    self.exit_kind_updated_at = Time.zone.now
  end
end
