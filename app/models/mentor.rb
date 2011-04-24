class Mentor < User

  field :name
  field :address
  field :phone
  field :personnel_number
  field :field_of_study
  field :education
  field :etcs, :type => Boolean
  field :entry_date, :type => Date

end
