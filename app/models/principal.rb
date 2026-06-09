# frozen_string_literal: true

class Principal < User
  has_many :principal_school_relations, dependent: :destroy
  has_many :schools, through: :principal_school_relations

  validates :schools, presence: true
end
