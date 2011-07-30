class AddSecondaryActiveToKid < ActiveRecord::Migration
  def self.up
    add_column :kids, :secondary_active, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :kids, :secondary_active
  end
end
