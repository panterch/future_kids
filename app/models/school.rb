class School < ApplicationRecord
  validates :name, presence: true

  default_scope { order(:name) }

  has_many :principal_school_relations
  has_many :principals, through: :principal_school_relations
  has_many :teachers
  has_many :kids
  has_many :mentors, through: :kids

  enum :school_kind,
       { high_school: 'high_school', gymnasium: 'gymnasium', secondary_school: 'secondary_school',
         primary_school: 'primary_school' }

  def active_teachers
    teachers.active
  end

  def active_principals
    principals.active
  end

  def display_name
    name
  end

  def human_school_kind
    return nil unless school_kind

    School.humanize_enum('school_kind', school_kind)
  end

  def self.by_kind(role)
    case role
    when :mentor
      high_school + gymnasium
    when :teacher
      primary_school + secondary_school
    when :kid
      primary_school + secondary_school
    end
  end
end
