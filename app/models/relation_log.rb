class RelationLog < ApplicationRecord
  belongs_to :kid, optional: true
  belongs_to :user, optional: true

  default_scope { order(:created_at) }
end
