class AddAdditionalFieldsToKid < ActiveRecord::Migration
  def self.up
    add_column :kids, :dob, :date
    add_column :kids, :language, :string
    add_column :kids, :translator, :boolean
    add_column :kids, :goal_1, :text
    add_column :kids, :goal_2, :text
  end

  def self.down
    remove_column :kids, :goal_2
    remove_column :kids, :goal_1
    remove_column :kids, :translator
    remove_column :kids, :language
    remove_column :kids, :dob
  end
end
