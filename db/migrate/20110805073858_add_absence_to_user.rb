class AddAbsenceToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :absence, :text
  end

  def self.down
    remove_column :users, :absence
  end
end
