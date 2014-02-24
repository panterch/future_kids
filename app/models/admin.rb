class Admin < User

  has_many :coachings, :class_name => 'Kid'

  after_save :release_relations, :if => :inactive?

protected

  def release_relations
    self.coachings.clear
  end

end
