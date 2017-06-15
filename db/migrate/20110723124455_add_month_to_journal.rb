class AddMonthToJournal < ActiveRecord::Migration[4.2]
  def self.up
    add_column :journals, :month, :integer
    add_index :journals, :month
    # calculate month for existing records by using the before_save hook
    Journal.all.each(&:save!)
  end

  def self.down
    remove_column :journals, :month
  end
end
