# frozen_string_literal: true

json.mentors do
  @mentors.each do |mentor|
    json.set! mentor.id do
      json.id mentor.id
      json.prename mentor.prename
      json.name mentor.name
      json.sex mentor.sex
      json.ects mentor.ects
      json.kids mentor.kids, :id, :name, :prename
      json.secondary_kids mentor.secondary_kids, :id, :name, :prename
      json.schools mentor.schools.ids
      json.schedules create_schedules_nested_set(mentor.schedules)
    end
  end
end

json.kid do
  json.id @kid.id
  json.prename @kid.prename
  json.name @kid.name
  json.mentor_id @kid.mentor_id
  json.meeting_start_at meeting_start_time
  json.meeting_day meeting_day
  json.secondary_mentor_id @kid.secondary_mentor_id
  json.schedules create_schedules_nested_set(@kid.schedules)
end

json.schools @schools, :id, :display_name
