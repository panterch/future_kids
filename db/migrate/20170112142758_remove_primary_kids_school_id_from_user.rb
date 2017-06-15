class RemovePrimaryKidsSchoolIdFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :primary_kids_school_id, :integer
  end
end
