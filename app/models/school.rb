class School < ApplicationRecord
  validates_presence_of :name

  default_scope { order(:name) }

  has_many :principal_school_relations
  has_many :principals, through: :principal_school_relations
  has_many :teachers
  has_many :kids
  has_many :mentors, through: :kids

  def active_teachers
    self.teachers.active
  end

  def active_principals
    self.principals.active
  end

  def display_name
    name
  end
end
