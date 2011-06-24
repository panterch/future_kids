class Journal < ActiveRecord::Base

  belongs_to :kid
  belongs_to :mentor

  def display_name
    return "Neuer Lernjournal Eintrag" if new_record?
    "Journal vom #{I18n.l(held_at.to_date)}"
  end

  def human_goal; goal.try(:textilize); end
  def human_subject; subject.try(:textilize); end
  def human_method; method.try(:textilize); end
  def human_outcome; outcome.try(:textilize); end

end
