class Mentor < User

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'
  has_many :journals

end
