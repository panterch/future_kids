class RemoveSchoolFromKids < ActiveRecord::Migration
  def up
    remove_column :kids, :school
  end

  def down
    add_column :kids, :school, :string
  end
end
