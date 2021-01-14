class School < ApplicationRecord
  validates_presence_of :name

  default_scope { order(:name) }

  has_many :principal_school_relations
  has_many :principals, through: :principal_school_relations
  has_many :teachers
  has_many :kids
  has_many :mentors, through: :kids

  enum school_kind: { high_school: 'high_school', gymnasium: 'gymnasium', secondary_school: 'secondary_school', primary_school: 'primary_school' }

  def active_teachers
    self.teachers.active
  end

  def active_principals
    self.principals.active
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
        self.high_school + self.gymnasium
      when :teacher
        self.primary_school + self.secondary_school
      when :kid
        self.primary_school + self.secondary_school
    end
  end
end
