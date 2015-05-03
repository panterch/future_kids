class Mentor < User
  has_many :kids
  has_many :secondary_kids, class_name: 'Kid',
                            foreign_key: 'secondary_mentor_id'
  has_many :journals
  has_many :reminders
  has_many :secondary_reminders, class_name: 'Reminder',
                                 foreign_key: 'secondary_mentor_id'
  has_many :schedules, as: :person
  belongs_to :primary_kids_school, class_name: 'School'
  belongs_to :primary_kids_admin, class_name: 'Admin'

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

  def human_primary_kids_meeting_day
    return nil if primary_kids_meeting_day.nil?
    I18n.t('date.day_names')[primary_kids_meeting_day]
  end

  def total_duration
    journals.sum(:duration)
  end

  def month_count
    Journal.unscoped.where(mentor_id: id).map do |j|
      "#{j.month} #{j.year}"
    end.uniq.size
  end

  def human_exit_kind
    return '' if exit_kind.blank?
    I18n.t(exit_kind, scope: 'exit_kind')
  end

  protected

  # inactive mentors should not be connected to other persons
  def release_relations
    kids.clear
    secondary_kids.clear
  end
end
