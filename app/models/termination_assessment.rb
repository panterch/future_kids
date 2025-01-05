class TerminationAssessment < ApplicationRecord
  include ActionView::Helpers::TextHelper

  default_scope { order('held_at DESC') }

  belongs_to :kid
  belongs_to :teacher
  belongs_to :created_by, class_name: 'User'

  validates_presence_of :kid, :teacher, :held_at, :created_by
  validates_date :held_at, after: '2001-01-01'

  after_create :send_notification

  def display_name
    return 'Neues Abschluss-Feedback' if new_record?
    return "Abschluss-Feedback vom #{I18n.l(held_at.to_date)}" if held_at
  end

  def initialize_default_values(kid)
    self.held_at = Date.today
    self.kid_id = kid.id
    self.teacher_id = kid.teacher_id
  end

  def human_development
    text_format(development)
  end

  def human_goals
    text_format(goals)
  end

  def human_collaboration
    text_format(collaboration)
  end

  def human_improvements
    text_format(improvements)
  end

  def human_note
    text_format(note)
  end

  def human_goals_reached
    return '' if goals_reached.empty?
    I18n.t(goals_reached, scope: 'quaternary')
  end

  protected

  def send_notification
    Notifications.termination_assessment_created(self).deliver_later
  end
end
