class AddSchoolIdToKid < ActiveRecord::Migration
  def change
    add_column :kids, :school_id, :integer
    add_index :kids, :school_id
  end
end
