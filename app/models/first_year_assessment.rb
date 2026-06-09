# frozen_string_literal: true

class FirstYearAssessment < ApplicationRecord
  default_scope { order(held_at: :desc) }

  belongs_to :kid
  belongs_to :teacher
  belongs_to :mentor
  belongs_to :created_by, class_name: 'User'

  validates :held_at, :teacher, :mentor, presence: true

  # the html5 date submit allows two letter dates (e.g. '21') and translates them to wrong years (like '0021')
  validates_date :held_at, after: '2001-01-01'

  after_create :send_notification

  def display_name
    return 'Neues Auswertungsgespräch' if new_record?

    "Auswertungsgespräch vom #{I18n.l(held_at.to_date)}" if held_at
  end

  def initialize_default_values(kid)
    self.held_at = Time.zone.today
    self.kid_id = kid.id
    self.teacher_id = kid.teacher_id
    self.mentor_id = kid.mentor_id
    self.breaking_off = false
  end

  def human_duration
    return '' if duration.nil?

    "#{duration} Minuten"
  end

  human_text_attributes :development_teacher, :development_mentor, :goals_teacher, :goals_mentor,
                        :relation_mentor, :motivation, :collaboration, :breaking_reason,
                        :goal_1, :goal_2, :goal_3, :improvements, :note

  protected

  def send_notification
    Notifications.first_year_assessment_created(self).deliver_later
  end
end
