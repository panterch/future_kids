class School < ActiveRecord::Base
  attr_accessible :name, :principal_id

  validates_presence_of :name
end
