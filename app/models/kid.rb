class Kid
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  embeds_many :journals

  field :name
  field :prename

  accepts_nested_attributes_for :journals

  # prepares a new unsaved journal entry based on the last entry made
  def prepare_new_journal_entry
    journals.build(:held_at => Date.today)
  end

end
