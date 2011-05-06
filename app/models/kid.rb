class Kid
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  embeds_many :journals
  embeds_many :reviews

  field :name
  field :prename

  accepts_nested_attributes_for :journals, :reviews,
    :reject_if => proc { |attributes| empty_nested_entry?(attributes) }

  # prepares a new unsaved journal entry based on the last entry made
  def prepare_new_journal_entry
    journals.build(:held_at => Date.today)
  end

  def prepare_new_review_entry
    reviews.build(:held_at => Date.today)
  end

  # entries that were just built by the prepare_ methods should not be saved
  # we detect them by checking for non-blank parameters other than held_at
  def self.empty_nested_entry?(attributes)
    attributes.each do |key, value|
      next if key.starts_with?('held_at')
      return false unless value.blank?
    end
    true
  end

  def display_name
    [ prename, name].reject(&:blank?).join(' ')
  end

end
