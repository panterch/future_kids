class RemoveSchoolFromKids < ActiveRecord::Migration[4.2]
  def up
    remove_column :kids, :school
  end

  def down
    add_column :kids, :school, :string
  end
end
