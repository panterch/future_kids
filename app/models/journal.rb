class Journal < ActiveRecord::Base

  default_scope :order => 'held_at DESC'

  belongs_to :kid
  belongs_to :mentor

  validates_presence_of :kid, :mentor, :held_at, :start_at, :end_at

  before_save :calculate_duration

  def display_name
    return "Neuer Lernjournal Eintrag" if new_record?
    "Journal vom #{I18n.l(held_at.to_date)}"
  end

  def human_goal; goal.try(:textilize); end
  def human_subject; subject.try(:textilize); end
  def human_method; method.try(:textilize); end
  def human_outcome; outcome.try(:textilize); end
  
  def human_start_at; I18n.l(start_at, :format => :time); end
  def human_end_at; I18n.l(end_at, :format => :time); end

protected

  def calculate_duration
    self.duration = (end_at - start_at) / 60
  end

end
