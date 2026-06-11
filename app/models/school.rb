# frozen_string_literal: true

class School < ApplicationRecord
  validates :name, presence: true

  default_scope { order(:name) }
  scope :active, -> { where(inactive: false) }

  before_save :track_inactive
  validate :no_active_dependents_when_inactive

  has_many :principal_school_relations, dependent: :destroy
  has_many :principals, through: :principal_school_relations
  has_many :teachers, dependent: :nullify
  has_many :kids, dependent: :nullify
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

  human_rails_enum_attributes :school_kind

  def self.by_kind(role)
    case role
    when :mentor
      high_school + gymnasium
    when :teacher, :kid
      primary_school + secondary_school
    end
  end

  private

  def track_inactive
    return unless inactive_changed?

    self.inactive_at = inactive? ? Time.zone.now : nil
  end

  def no_active_dependents_when_inactive
    return unless inactive? && inactive_changed?
    return unless kids.active.any? || teachers.active.any?

    errors.add(:inactive, :has_active_dependents)
  end
end
