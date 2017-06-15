class AdaptKids < ActiveRecord::Migration[4.2]
  def self.up
    add_column :kids, :note, :text
    remove_column :kids, :goal
  end

  def self.down
    add_column :kids, :goal, :text
    remove_column :kids, :note
  end
end
