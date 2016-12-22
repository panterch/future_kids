class Admin < User
  has_many :coachings, class_name: 'Kid'
  has_many :mentors, through: :coachings

  after_save :release_relations, if: :inactive?

  protected

  def release_relations
    coachings.clear
  end
end
