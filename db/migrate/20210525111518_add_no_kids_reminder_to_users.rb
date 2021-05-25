class AddNoKidsReminderToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :no_kids_reminder, :boolean, default: true
  end
end
