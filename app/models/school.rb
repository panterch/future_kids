class School < ActiveRecord::Base
  attr_accessible :name, :principal_id

  validates_presence_of :name

  default_scope :order => :name

  def display_name
    name
  end
end
