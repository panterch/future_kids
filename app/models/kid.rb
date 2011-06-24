class Kid < ActiveRecord::Base

  # default_scope :ascending => [ :name, :prename ]

  belongs_to :mentor
  belongs_to :secondary_mentor, :class_name => 'Mentor'
  belongs_to :teacher
  belongs_to :secondary_teacher, :class_name => 'Teacher'

  has_many :journals
  has_many :reviews

  accepts_nested_attributes_for :journals, :reviews,
    :reject_if => proc { |attributes| empty_nested_entry?(attributes) }

  # prepares a new unsaved journal entry based on the last entry made
  def prepare_new_journal_entry
    journals.build(:held_at => Date.today)
  end

  def prepare_new_review_entry
    reviews.build(:held_at => Date.today)
  end

  def journals_sorted
    sort_by_new_record_and_held_at(journals)
  end

  def reviews_sorted
    sort_by_new_record_and_held_at(reviews)
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
    return "Neuer Eintrag" if new_record?
    [ name, prename ].reject(&:blank?).join(' ')
  end

  def human_goal; goal.try(:textilize); end

  def human_sex
    { 'm' => '♂', 'f' => '♀' }[sex]
  end

  # mongoid doesn't such a good job when sorting embedded fields (there is an
  # open bug). we sort them manually:
  # * new_records should always be on top
  # * other records are sorted by their date
  def sort_by_new_record_and_held_at(collection)
    collection.sort do |a,b|
      if a.new_record?
        -1
      elsif b.new_record?
        1
      else
        b.held_at <=> a.held_at
      end
    end
  end

end
