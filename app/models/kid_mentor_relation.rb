class KidMentorRelation < ActiveRecord::Base

  self.primary_key = 'kid_id' # use kid id to identify records

  belongs_to :kid
  belongs_to :mentor
  belongs_to :admin

  default_scope { includes(:kid, :mentor, :admin) }

  def self.reset_all
    Kid.unscoped.active.update_all(exit_kind: nil, exit_at: nil)
    Mentor.unscoped.active.update_all(exit_kind: nil, exit_at: nil)
  end

  # inactivates mentor and kid at once - see #inactivatable
  # for precondition
  def self.inactivate(kid_id)
    kid = Kid.find(kid_id)
    kid.mentor.update_attribute(:inactive, true)
    kid.update_attribute(:inactive, true)
  end

  # checks elements of relation for candidates of inactivation
  def inactivatable?
    return false unless 'exit' == kid.exit_kind
    return false unless 'exit' == kid.mentor.exit_kind
    return true
  end

  # model is connected to an SQL view
  def readonly?
    true
  end
end
