class Kid < ActiveRecord::Base

  default_scope { order(:name, :prename) }

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :teacher
  belongs_to :secondary_teacher, :class_name => 'Teacher'
  belongs_to :admin
  belongs_to :school

  has_many :journals
  has_many :reviews
  has_many :reminders
  has_many :schedules, :as => :person
  has_many :relation_logs

  accepts_nested_attributes_for :journals, :reviews, :schedules

  validates_presence_of :name, :prename

  validates_numericality_of :meeting_day, :only_integer => true, :allow_blank => true,
                            :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5

  after_save :sync_school_field_with_mentor
  after_save :track_relations
  after_validation :release_relations, :if => :inactive?

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
    journals.where(:week => time.strftime('%U').to_i, :year => time.year).first
  end

  # tries to retrieve the reminder for the week given by time
  def reminder_entry_for_week(time = Time.now)
    time = calculate_meeting_time(time)
    return nil if time.nil?
    reminders.where(:week => time.strftime('%U').to_i, :year => time.year).first
  end

  # checks wether a journal entry is already due for the week given by time
  def journal_entry_due?(time = Time.now)
    meeting_time = calculate_meeting_time(time)
    return false if meeting_time.nil?
    (meeting_time + 1.day) < time
  end

  # when controlling reminders it is useful to know the date of the most recent
  # journal entry made for the associated kid
  def last_journal_entry
    journals.order('held_at DESC').first
  end

  def display_name
    return "Neuer Eintrag" if new_record?
    [ name, prename ].reject(&:blank?).join(' ')
  end

  def human_goal; goal.try(:textilize); end

  def human_todo; todo.try(:textilize); end

  def human_abnormality; abnormality.try(:textilize); end

  def human_abnormality_criticality
    return '' unless abnormality_criticality
    I18n.t(abnormality_criticality, :scope => 'kids.criticality')
  end

  def human_relation_archive; relation_archive.try(:textilize); end

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

  # mentors can be filtered by the scool of their primary kids. therefore we use
  # a field on mentor which has to be synced on each write
  def sync_school_field_with_mentor
    if self.mentor
      self.mentor.update_attributes(
        :primary_kids_school_id => self.school_id,
        :primary_kids_meeting_day => self.meeting_day)
    elsif self.mentor_id_was
      Mentor.find(self.mentor_id_was).update_attributes(
        :primary_kids_school_id => nil,
        :primary_kids_meeting_day => nil)
    end
  end

protected

  def release_relations
    self.relation_archive =
      "#{Kid.human_attribute_name(:mentor)}: #{self.mentor.try(:display_name)}\n"
    self.relation_archive <<
      "#{Kid.human_attribute_name(:secondary_mentor)}: #{self.secondary_mentor.try(:display_name)}\n"
    self.relation_archive <<
      "#{Kid.human_attribute_name(:teacher)}: #{self.teacher.try(:display_name)}\n"
    self.relation_archive <<
      "#{Kid.human_attribute_name(:secondary_teacher)}: #{self.secondary_teacher.try(:display_name)}"
    self.mentor = nil
    self.secondary_mentor = nil
    self.teacher = nil
    self.secondary_teacher = nil
    self.admin = nil
  end

  def track_relations
    self.track_relation(:mentor)
    self.track_relation(:secondary_mentor)
    self.track_relation(:teacher)
    self.track_relation(:secondary_teacher)
    self.track_relation(:admin)
  end

  # create a relation log for the given field if it has changed
  def track_relation(field)
    changed = self.send("#{field}_id_changed?")
    current_id = self.send("#{field}_id")
    previous_id = self.send("#{field}_id_was")
    if changed && previous_id
      relation_logs.create!(:user_id => self.send("#{field}_id_was"),
                            :role => field,
                            :end_at => Time.now)

    end
    if changed && current_id
      relation_logs.create!(:user_id => self.send("#{field}_id"),
                            :role => field,
                            :start_at => Time.now)
    end
  end

end
