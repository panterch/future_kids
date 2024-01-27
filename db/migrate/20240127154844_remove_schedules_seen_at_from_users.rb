class RemoveSchedulesSeenAtFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :schedules_seen_at, :datetime
  end
end
