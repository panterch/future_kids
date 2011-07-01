class Kid < ActiveRecord::Base

  default_scope :order => [ :name, :prename ]

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :teacher
  belongs_to :secondary_teacher, :class_name => 'Teacher'

  has_many :journals
  has_many :reviews

  accepts_nested_attributes_for :journals, :reviews

  def display_name
    return "Neuer Eintrag" if new_record?
    [ name, prename ].reject(&:blank?).join(' ')
  end

  def human_goal; goal.try(:textilize); end

  def human_sex
    { 'm' => '♂', 'f' => '♀' }[sex]
  end

  def human_meeting_day; I18n.t('date.day_names')[meeting_day]; end
  def human_meeting_start_at; I18n.l(meeting_start_at, :format => :time); end

end
