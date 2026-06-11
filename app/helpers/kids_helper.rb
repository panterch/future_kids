# frozen_string_literal: true

module KidsHelper
  def meeting_start_time(kid)
    return nil if kid.meeting_start_at.blank?

    kid.meeting_start_at.strftime('%H:%M')
  end

  def meeting_day(kid)
    return nil if kid.meeting_day.blank?

    kid.meeting_day
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

  def schedule_time_key(time)
    "#{time.hour.to_s.rjust(2, '0')}:#{time.minute.to_s.rjust(2, '0')}"
  end
end
