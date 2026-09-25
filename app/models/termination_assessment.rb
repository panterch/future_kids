# frozen_string_literal: true

class TerminationAssessment < ApplicationRecord
  default_scope { order(held_at: :desc) }

  belongs_to :kid
  belongs_to :teacher
  belongs_to :created_by, class_name: 'User'

  validates :held_at, :teacher, presence: true
  validates :held_at, comparison: { greater_than: Date.new(2001, 1, 1) }, allow_blank: true

  after_create :send_notification

  def display_name
    return 'Neues Abschluss-Feedback' if new_record?

    "Abschluss-Feedback vom #{I18n.l(held_at.to_date)}" if held_at
  end

  def initialize_default_values(kid)
    self.held_at = Time.zone.today
    self.kid_id = kid.id
    self.teacher_id = kid.teacher_id
  end

  enum :goals_reached, { yes: 'yes', mostly: 'mostly', partially: 'partially', no: 'no' }

  human_text_attributes :development, :goals, :collaboration, :improvements, :note
  human_rails_enum_attributes :goals_reached

  protected

  def send_notification
    NotificationsMailer.termination_assessment_created(self).deliver_later
  end
end
