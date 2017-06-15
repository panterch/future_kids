class AddMeetingDayToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :primary_kids_meeting_day, :integer
  end
end
