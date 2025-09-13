class FirstYearAssessment < ApplicationRecord
  include ActionView::Helpers::TextHelper

  default_scope { order('held_at DESC') }

  belongs_to :kid
  belongs_to :teacher
  belongs_to :mentor
  belongs_to :created_by, class_name: 'User'

  validates :kid, :teacher, :mentor, :held_at, :created_by, presence: true

  # the html5 date submit allows two letter dates (e.g. '21') and translates them to wrong years (like '0021')
  validates_date :held_at, after: '2001-01-01'

  after_create :send_notification

  def display_name
    return 'Neues Auswertungsgespräch' if new_record?

    "Auswertungsgespräch vom #{I18n.l(held_at.to_date)}" if held_at
  end

  def initialize_default_values(kid)
    self.held_at = Date.today
    self.kid_id = kid.id
    self.teacher_id = kid.teacher_id
    self.mentor_id = kid.mentor_id
    self.breaking_off = false
  end

  def human_duration
    return '' if duration.nil?

    "#{duration} Minuten"
  end

  def human_development_teacher
    text_format(development_teacher)
  end

  def human_development_mentor
    text_format(development_mentor)
  end

  def human_goals_teacher
    text_format(goals_teacher)
  end

  def human_goals_mentor
    text_format(goals_mentor)
  end

  def human_relation_mentor
    text_format(relation_mentor)
  end

  def human_motivation
    text_format(motivation)
  end

  def human_collaboration
    text_format(collaboration)
  end

  def human_breaking_reason
    text_format(breaking_reason)
  end

  def human_goal_1
    text_format(goal_1)
  end

  def human_goal_2
    text_format(goal_2)
  end

  def human_goal_3
    text_format(goal_3)
  end

  def human_improvements
    text_format(improvements)
  end

  def human_note
    text_format(note)
  end

  protected

  def send_notification
    Notifications.first_year_assessment_created(self).deliver_later
  end
end
