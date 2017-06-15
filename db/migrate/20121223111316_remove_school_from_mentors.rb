class RemoveSchoolFromMentors < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :primary_kids_school
    add_column :users, :primary_kids_school_id, :integer
  end

  def down
    add_column :users, :primary_kids_school, :string
    remove_column :users, :primary_kids_school_id
  end
end
