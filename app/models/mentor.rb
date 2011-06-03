class Mentor < User

  default_scope :ascending => [ :name, :prename ]

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_mentor_id'

  field :address
  field :phone
  field :personnel_number
  field :field_of_study
  field :education
  field :etcs, :type => Boolean
  field :entry_date, :type => Date

end
