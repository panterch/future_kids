class Principal < User
  has_many :principal_school_relations
  has_many :schools, through: :principal_school_relations

  validates_presence_of :schools
end
