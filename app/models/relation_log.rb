class RelationLog < ActiveRecord::Base
  belongs_to :kid
  belongs_to :user
end
