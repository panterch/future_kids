class RemovePrimaryKidsSchoolIdFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :primary_kids_school_id, :integer
  end
end
