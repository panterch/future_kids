class Mentor < User

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'
  has_many :journals
  has_many :reminders
  has_many :secondary_reminders, :class_name => 'Reminder',
           :foreign_key => 'secondary_mentor_id'
  has_many :schedules, :as => :person

end
