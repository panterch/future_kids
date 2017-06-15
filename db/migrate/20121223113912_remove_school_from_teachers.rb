class RemoveSchoolFromTeachers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :school
  end

  def down
    add_column :users, :school, :string
  end
end
