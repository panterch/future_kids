class Principal < User
  belongs_to :school
  validates_presence_of :school
end
