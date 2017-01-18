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

  # Unscope is needed because the association is done through kids.
  # Kids are ordered so distinct was looking at the kids scope in order to
  # produce distinct results. Unscoping order enables distinct to remove duplicates.
  has_many :schools, -> {unscope(:order).distinct}, through: :kids

  accepts_nested_attributes_for :schedules

  after_save :release_relations, if: :inactive?

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

  def month_count
    Journal.unscoped.where(mentor_id: id).select('DISTINCT (month, year)').count
  end

  def human_exit_kind
    return '' if exit_kind.blank?
    I18n.t(exit_kind, scope: 'exit_kind')
  end

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
end