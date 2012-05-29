class Comment < ActiveRecord::Base
  attr_accessible :body, :by

  default_scope :order => 'id'
  validates_presence_of :body, :by, :journal_id
  
  def display_name
    return "Neuer Kommentar" if new_record?
    return "Kommentar vom #{I18n.l(created_at.to_date)} von #{by}"
  end

end
