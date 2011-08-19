class Mentor < User

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'
  has_many :journals
  has_many :reminders
  has_many :secondary_reminders, :class_name => 'Reminder',
           :foreign_key => 'secondary_mentor_id'
  has_many :schedules, :as => :person

  def self.mentors_grouped_by_assigned_kids
    groups = { :both => [], :only_primary => [], :only_secondary => [], :none => [] }
    Mentor.all.each do |m|
      case [ m.kids.present?, m.secondary_kids.present? ]
      when [ true, true ]; groups[:both] << m
      when [ true, false ]; groups[:only_primary] << m
      when [ false, true ]; groups[:only_secondary] << m
      when [ false, false ]; groups[:none] << m
      end
    end
    groups
  end

end
