class Teacher < User

  has_many :kids
  has_many :secondary_kids, :class_name => 'Kid',
           :foreign_key => 'secondary_teacher_id'

  after_save :release_relations, :if => :inactive?

protected

  # inactive mentors should not be connected to other persons
  def release_relations
    self.kids.clear
    self.secondary_kids.clear
  end


end
