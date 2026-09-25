# frozen_string_literal: true

module KidsHelper
  # Layout of the goal checkboxes (Kid::GOALS_1 / GOALS_2) shared by
  # kids/_form and kids/_show (see GOAL_SECTIONS below):
  # card title => [[sub-group label, goals], ...].
  # A nil label means the goals sit directly in the card, without a group.
  SUBJECT_GOAL_CARDS = {
    'Deutsch' => [
      ['Hören', %i[goal_3 goal_4 goal_5]],
      ['Lesen', %i[goal_6 goal_7 goal_8]],
      ['Sprechen', %i[goal_9 goal_10]],
      ['Schreiben', %i[goal_11 goal_12 goal_13]],
      ['Sprache im Fokus (Grammatik und Rechtschreibung)', %i[goal_14 goal_15]]
    ],
    'Mathematik' => [
      [nil, %i[goal_16]],
      ['Zahl und Variable', %i[goal_17 goal_18 goal_19 goal_20]],
      ['Form und Raum', %i[goal_21 goal_22]],
      ['Grössen', %i[goal_23 goal_24]]
    ]
  }.freeze

  GENERAL_GOAL_CARDS = {
    'Personale Förderbereiche' => [[nil, %i[goal_25 goal_26 goal_27 goal_28 goal_29 goal_30 goal_31]]],
    'Methodische Förderbereiche' => [[nil, %i[goal_32 goal_33 goal_34 goal_35]]]
  }.freeze

  # heading, free-text goal field, max. number of checked goals, cards
  GOAL_SECTIONS = [
    ['Fachliche Förderbereiche', :goal_1, Kid::GOALS_1_MAX, SUBJECT_GOAL_CARDS],
    ['Überfachliche Förderbereiche', :goal_2, Kid::GOALS_2_MAX, GENERAL_GOAL_CARDS]
  ].freeze

  def meeting_start_time(kid)
    return nil if kid.meeting_start_at.blank?

    kid.meeting_start_at.strftime('%H:%M')
  end

  # Props for the React component on show_kid_mentors_schedules
  def kid_mentor_schedules_data(kid, mentors, schools)
    {
      mentors: mentors.to_h { |mentor| [mentor.id.to_s, mentor_schedules_data(mentor)] },
      kid: {
        id: kid.id,
        prename: kid.prename,
        name: kid.name,
        mentor_id: kid.mentor_id,
        meeting_start_at: meeting_start_time(kid),
        meeting_day: kid.meeting_day.presence,
        secondary_mentor_id: kid.secondary_mentor_id,
        schedules: create_schedules_nested_set(kid.schedules)
      },
      schools: schools.map { |school| { id: school.id, display_name: school.display_name } }
    }
  end

  # Transforms a schedule array into a nested hash for the React component.
  # Entry set[day]["HH:MM"] is true when that slot is available.
  def create_schedules_nested_set(schedules_array)
    schedules_set = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = {} } }
    schedules_array.group_by(&:day).each do |day, times|
      times.each { |t| schedules_set[day][schedule_time_key(t)] = true }
    end
    schedules_set
  end

  private

  def mentor_schedules_data(mentor)
    {
      id: mentor.id,
      prename: mentor.prename,
      name: mentor.name,
      sex: mentor.sex,
      ects: mentor.ects,
      kids: mentor.kids.map { |k| { id: k.id, name: k.name, prename: k.prename } },
      secondary_kids: mentor.secondary_kids.map { |k| { id: k.id, name: k.name, prename: k.prename } },
      schools: mentor.schools.ids,
      schedules: create_schedules_nested_set(mentor.schedules)
    }
  end

  def schedule_time_key(time)
    "#{time.hour.to_s.rjust(2, '0')}:#{time.minute.to_s.rjust(2, '0')}"
  end
end
