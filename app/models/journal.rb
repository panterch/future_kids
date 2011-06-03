class Journal
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  embedded_in :kid

  field :held_at, :type => Date
  field :goal
  field :subject
  field :method
  field :outcome

  def display_name
    return "Neuer Lernjournal Eintrag" if new_record?
    "Journal vom #{I18n.l(held_at.to_date)}"
  end

  def human_goal; goal.try(:textilize); end
  def human_subject; subject.try(:textilize); end
  def human_method; method.try(:textilize); end
  def human_outcome; outcome.try(:textilize); end

end
