class AddMeetingLocationToJournals < ActiveRecord::Migration[6.0]
  def change
    add_column :journals, :meeting_type, :integer
  end
end
