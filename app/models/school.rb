class School < ActiveRecord::Base
  validates_presence_of :name

  default_scope { order(:name) }

  has_many :principal_school_relations
  has_many :principals, through: :principal_school_relations
  has_many :teachers

  def display_name
    name
  end
end
