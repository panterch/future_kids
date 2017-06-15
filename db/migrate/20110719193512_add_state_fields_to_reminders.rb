class AddStateFieldsToReminders < ActiveRecord::Migration[4.2]
  def self.up
    add_column :reminders, :acknowledged_at, :timestamp
  end

  def self.down
    remove_column :reminders, :acknowledged_at
  end
end
