class AddSecondaryActiveToKid < ActiveRecord::Migration[4.2]
  def self.up
    add_column :kids, :secondary_active, :boolean, null: false, default: false
  end

  def self.down
    remove_column :kids, :secondary_active
  end
end
