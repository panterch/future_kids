# frozen_string_literal: true

class Journal < ApplicationRecord
  default_scope { order('held_at DESC', :id).joins(:kid) }

  belongs_to :kid
  belongs_to :mentor
  has_many :comments, -> { order(:created_at) }, dependent: :destroy, inverse_of: :journal

  enum :meeting_type, { physical: 0, virtual: 1 }

  validates :held_at, :meeting_type, presence: true
  validates :start_at, :end_at, presence: { unless: :cancelled }
  # the html5 date submit allows two letter dates (e.g. '21') and translates them to wrong years (like '0021')
  validates_date :held_at, after: '2001-01-01', allow_blank: true

  before_validation :clean_times, if: :cancelled
  before_save :calculate_duration
  before_save :calculate_week
  before_save :calculate_year
  before_save :calculate_month

  after_create :send_notification, if: :important

  def display_name
    return 'Neuer Lernjournal Eintrag' if new_record?
    # altough held_at is mandatory for saved records, it may
    # temporarily be nil (edit with invalid data), this has to
    # be guarded
    return "Journal vom #{I18n.l(held_at.to_date)}" if held_at

    'Journal'
  end

  human_text_attributes :goal, :subject, :method, :outcome, :note
  human_time_attributes :start_at, :end_at
  human_rails_enum_attributes :meeting_type

  # there is a default entry per month which represents the administrative
  # costs.
  #
  # This is display only yet.
  def self.coaching_entry(mentor, month, year)
    held_at = Date.new(year.to_i, month.to_i).end_of_month
    Journal.new(mentor: mentor, held_at: held_at, duration: 60)
  end

  protected

  def clean_times
    self.end_at = nil
    self.start_at = nil
  end

  def calculate_duration
    self.duration = (cancelled? ? 0 : (end_at - start_at) / 60)
  end

  def calculate_week
    self.week = held_at.strftime('%U').to_i
  end

  def calculate_year
    self.year = held_at.year
  end

  def calculate_month
    self.month = held_at.month
  end

  def send_notification
    Notifications.important_journal_created(self).deliver_later
  end
end
