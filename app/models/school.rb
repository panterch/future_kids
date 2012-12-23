class School < ActiveRecord::Base
  attr_accessible :name, :principal_id

  validates_presence_of :name

  def display_name
    name
  end
end
