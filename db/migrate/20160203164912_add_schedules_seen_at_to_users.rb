class AddSchedulesSeenAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :schedules_seen_at, :datetime
  end
end
