class Teacher < User

  default_scope :ascending => [ :name, :prename ]

  has_many :kids

  field :address
  field :phone

end
