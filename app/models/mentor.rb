class Mentor < User

  default_scope :ascending => [ :name, :prename ]

  has_one :kid
  has_one :secondary_kid, :class_name => 'Kid'

  field :name
  field :prename
  field :address
  field :phone
  field :personnel_number
  field :field_of_study
  field :education
  field :etcs, :type => Boolean
  field :entry_date, :type => Date

  validates_presence_of :name, :prename

  def display_name
    [ name, prename].reject(&:blank?).join(' ')
  end


end
