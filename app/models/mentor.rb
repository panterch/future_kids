class Mentor < User

#  default_scope :ascending => [ :name, :prename ]

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'

end
