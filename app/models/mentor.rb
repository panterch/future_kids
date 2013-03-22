class Mentor < User

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'
  has_many :journals
  has_many :reminders
  has_many :secondary_reminders, :class_name => 'Reminder',
           :foreign_key => 'secondary_mentor_id'
  has_many :schedules, :as => :person
  belongs_to :primary_kids_school, :class_name => 'School'

  accepts_nested_attributes_for :schedules

  after_save :release_relations, :if => :inactive?

  def self.mentors_grouped_by_assigned_kids
    groups = { :both => [], :only_primary => [], :only_secondary => [],
               :none => [], :substitute => [] }
    Mentor.active.each do |m|
      if m.substitute?
        groups[:substitute] << m
        next
      end
      case [ m.kids.present?, m.secondary_kids.present? ]
      when [ true, true ]; groups[:both] << m
      when [ true, false ]; groups[:only_primary] << m
      when [ false, true ]; groups[:only_secondary] << m
      when [ false, false ]; groups[:none] << m
      end
    end
    groups
  end

protected

  # inactive mentors should not be connected to other persons
  def release_relations
    self.kids.clear
    self.secondary_kids.clear
  end

end
