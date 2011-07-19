class AddStateFieldsToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :acknowledged_at, :timestamp
  end

  def self.down
    remove_column :reminders, :acknowledged_at
  end
end
