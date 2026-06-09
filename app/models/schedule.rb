# frozen_string_literal: true

class Schedule < ApplicationRecord
  belongs_to :person, polymorphic: true

  validates :day, numericality: { only_integer: true,
                                  greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :hour, numericality: { only_integer: true,
                                   greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :minute, numericality: { only_integer: true,
                                     greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }

  validates :person_id, uniqueness: { scope: %i[person_type day hour minute] }

  MIN_HOUR = 13
  MAX_HOUR = 18
  LAST_MEETING_HOUR = 17
  LAST_MEETING_MIN = 30

  # overwrite == to simplificate comparison of collections
  def ==(other)
    other.is_a?(Schedule) &&
      day == other.day && hour == other.hour && minute == other.minute
  end

  # builds schedule entries for one week ordered by time
  # returns an array containing arrays for each day
  # [ [schedule_day_1, another_schedule_day_1 ]
  #   [schedule_day_2, another_schedule_day_2 ] ]
  def self.build_week
    (1..5).map do |day|
      (MIN_HOUR..MAX_HOUR).map do |hour|
        [0, 30].map do |minute|
          Schedule.new(day: day, hour: hour, minute: minute)
        end
      end.flatten
    end
  end

  def human_day
    return nil if day.nil?

    I18n.t('date.day_names')[day]
  end

  def human_hour
    return nil if hour.nil?

    format('%02d', hour)
  end

  def human_minute
    return nil if minute.nil?

    format('%02d', minute)
  end

  def last_meeting?
    return false if hour != LAST_MEETING_HOUR

    minute == LAST_MEETING_MIN
  end

  # shows when last schedules entry was edited for relation
  def self.schedules_updated_at(relation)
    relation.schedules.order(updated_at: :desc).first&.updated_at
  end
end
