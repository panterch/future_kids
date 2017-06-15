class AddSchedulesSeenAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :schedules_seen_at, :datetime
  end
end
