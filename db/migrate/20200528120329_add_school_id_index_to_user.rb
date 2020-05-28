class AddSchoolIdIndexToUser < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :school_id
  end
end
