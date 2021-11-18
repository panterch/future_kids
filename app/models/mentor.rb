class Mentor < User
  # Filters mentors by their kids coach. Used only in the mentor index form.
  attr_accessor :filter_by_coach_id
  # Filters mentors by their kids meeting day. Used only in the mentor index form.
  attr_accessor :filter_by_meeting_day
  # Filters mentors by their kids school. Used only in the mentor index form.
  attr_accessor :filter_by_school_id

  has_many :kids
  has_many :admins, through: :kids
  has_many :secondary_kids, class_name: 'Kid',
                            foreign_key: 'secondary_mentor_id'
  has_many :journals
  has_many :reminders
  has_many :secondary_reminders, class_name: 'Reminder',
                                 foreign_key: 'secondary_mentor_id'
  has_many :schedules, as: :person

  belongs_to :school, optional: true

  enum ects: { currently: 1, alumni: 2 }

  # Unscope is needed because the association is done through kids.
  # Kids are ordered so distinct was looking at the kids scope in order to
  # produce distinct results. Unscoping order enables distinct to remove duplicates.
  has_many :schools, -> {unscope(:order).distinct}, through: :kids

  has_many :mentor_matchings, dependent: :destroy

  accepts_nested_attributes_for :schedules

  after_save :release_relations, if: :inactive?

  validates_presence_of :sex, :address,
            :city, :photo, :dob, :phone, :school, if: :validate_public_signup_fields?

  # the html5 date submit allows two letter dates (e.g. '21') and translates them to wrong years (like '0021')
  validates_date :exit_at, after: '2001-01-01', allow_blank: true
  validates_date :dob, after: '1900-01-01', allow_blank: true

  def self.mentors_grouped_by_assigned_kids
    groups = { both: [], only_primary: [], only_secondary: [],
               none: [], substitute: [] }
    Mentor.active.each do |m|
      if m.substitute?
        groups[:substitute] << m
        next
      end
      case [m.kids.present?, m.secondary_kids.present?]
      when [true, true] then groups[:both] << m
      when [true, false] then groups[:only_primary] << m
      when [false, true] then groups[:only_secondary] << m
      when [false, false] then groups[:none] << m
      end
    end
    groups
  end

  def total_duration
    journals.sum(:duration)
  end

  def total_duration_last_month_with_coaching
    last_month = Date.today() - 1.month
    journals = self.journals.where(year: last_month.year, month: last_month.month).to_a
    journals << Journal.coaching_entry(self, last_month.month, last_month.year)
    journals.sum(&:duration)
  end

  def month_count
    Journal.unscoped.where(mentor_id: id).select('DISTINCT (month, year)').count
  end

  def human_exit_kind
    return '' if exit_kind.blank?
    I18n.t(exit_kind, scope: 'exit_kind')
  end

  def human_ects
    return '' if ects.blank?
    I18n.t(ects, scope: 'ects')
  end

  # shows when last schedule relation entry was edited
  def schedules_updated_at
    Schedule.schedules_updated_at(self)
  end

  def self.conditionally_send_no_kids_reminders
    Mentor.accepted.where(no_kids_reminder: true).find_each do |mentor|
      logger.info "[#{mentor.id}] #{mentor.display_name}: sending no kids reminder"
      Notifications.mentor_no_kids_reminder(mentor).deliver_later
    end
  end

  protected

  # inactive mentors should not be connected to other persons
  def release_relations
    kids.clear
    secondary_kids.clear
  end
end
