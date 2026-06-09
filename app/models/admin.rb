# frozen_string_literal: true

class Admin < User
  has_many :coachings, class_name: 'Kid', dependent: :nullify
  has_many :mentors, through: :coachings

  after_save :release_relations, if: :inactive?

  protected

  def release_relations
    coachings.clear
  end
end
