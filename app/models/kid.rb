class Kid < ActiveRecord::Base

  default_scope :order => [ :name, :prename ]

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :teacher
  belongs_to :secondary_teacher, :class_name => 'Teacher'

  has_many :journals
  has_many :reviews
  has_many :reminders
  has_many :schedules, :as => :person

  accepts_nested_attributes_for :journals, :reviews

  validates_numericality_of :meeting_day, :only_integer => true, :allow_blank => true,
                            :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5

  # takes the given time argument (or Time.now) and calculates the
  # date and time for that weeks meeting
  def calculate_meeting_time(time = Time.now)
    return nil if meeting_day.blank? || meeting_start_at.blank?
    time = time.monday
    time = time + (meeting_day - 1).days
    time = time + meeting_start_at.hour.hours
    time = time + meeting_start_at.min.minutes
    time
  end

  # tries to retrieve the journal entry for the week given by time
  def journal_entry_for_week(time = Time.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?
    journals.find(:first, :conditions => { :week => time.strftime('%U').to_i,
                                           :year => time.year })
  end

  # tries to retrieve the reminder for the week given by time
  def reminder_entry_for_week(time = Time.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?
    reminders.find(:first, :conditions => { :week => time.strftime('%U').to_i,
                                            :year => time.year })
  end


  # checks wether a journal entry is already due for the week given by time
  def journal_entry_due?(time = Time.now)
    meeting_time = calculate_meeting_time(time)
    return false if meeting_time.nil?
    (meeting_time + 1.day) < time
  end

  def display_name
    return "Neuer Eintrag" if new_record?
    [ name, prename ].reject(&:blank?).join(' ')
  end

  def human_goal; goal.try(:textilize); end

  def human_sex
    { 'm' => '♂', 'f' => '♀' }[sex]
  end

  def human_meeting_day
    return nil if meeting_day.nil?
    I18n.t('date.day_names')[meeting_day]
  end

  def human_meeting_start_at
    return nil if meeting_start_at.nil?
    I18n.l(meeting_start_at, :format => :time)
  end

end
