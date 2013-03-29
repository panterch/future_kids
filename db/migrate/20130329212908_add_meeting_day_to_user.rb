class AddMeetingDayToUser < ActiveRecord::Migration
  def change
    add_column :users, :primary_kids_meeting_day, :integer
  end
end
