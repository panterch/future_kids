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

  # Availability is classified by the number of complete 1.5 hour windows (3
  # *consecutive* 30 minute slots on the same day) a person (kid or mentor)
  # has entered. Scattered, non-consecutive slots - even many of them - never
  # count towards a window.
  #   none:    no complete window entered
  #   partial: up to two complete windows
  #   full:    more than two complete windows
  SLOTS_PER_WINDOW = 3
  MAX_PARTIAL_WINDOWS = 2
  AVAILABILITY_STATUSES = %w[none partial full].freeze

  # a "window" is counted via the classic gaps-and-islands technique: each
  # schedule row is given a slot index (hour * 2 + minute / 30) and grouped
  # with its consecutive neighbours on the same day by subtracting a
  # ROW_NUMBER() counted in the same order - consecutive slots end up with
  # the same (person_id, day, group) and are thus counted as one run, whose
  # length (integer-)divided by SLOTS_PER_WINDOW gives its window count.
  WINDOW_COUNTS_SQL = <<~SQL.squish
    SELECT person_id, SUM(run_length / #{SLOTS_PER_WINDOW}) AS window_count
    FROM (
      SELECT person_id, day, slot_group, COUNT(*) AS run_length
      FROM (
        SELECT person_id, day,
               (hour * 2 + minute / 30) - ROW_NUMBER() OVER (
                 PARTITION BY person_id, day ORDER BY hour, minute
               ) AS slot_group
        FROM schedules
        WHERE person_type = ?
      ) AS slots
      GROUP BY person_id, day, slot_group
    ) AS runs
    GROUP BY person_id
    HAVING SUM(run_length / #{SLOTS_PER_WINDOW}) > 0
  SQL

  # the number of complete 1.5 hour windows (see AVAILABILITY_STATUSES above)
  # each person of the given polymorphic type (person_type) has entered,
  # as a Schedule relation selecting person_id and window_count. people
  # without a single complete window aren't included at all.
  def self.window_counts(person_type)
    sql = sanitize_sql_array([WINDOW_COUNTS_SQL, person_type])
    from("(#{sql}) AS schedule_window_counts").select(:person_id, :window_count)
  end

  def self.availability_status(person)
    # the derived table above isn't the schedules table itself, so a Hash
    # condition here would wrongly qualify it as schedules.person_id, a table
    # no longer in the FROM clause
    # rubocop:disable-next Rails/WhereEquals
    window_count = window_counts(person.class.polymorphic_name)
                   .where('person_id = ?', person.id).pick(:window_count) || 0
    if window_count.zero?
      :none
    elsif window_count <= MAX_PARTIAL_WINDOWS
      :partial
    else
      :full
    end
  end

  # narrows a relation of kids or mentors to those with the given
  # availability status; an unknown or blank status leaves it untouched
  def self.filter_by_availability(people, status)
    return people unless AVAILABILITY_STATUSES.include?(status.to_s)

    counts = window_counts(people.klass.polymorphic_name)
    return people.where.not(id: counts.reselect(:person_id)) if status.to_s == 'none'

    comparison = status.to_s == 'partial' ? '<= ?' : '> ?'
    people.where(id: counts.where("window_count #{comparison}", MAX_PARTIAL_WINDOWS).reselect(:person_id))
  end

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
