class AddUpdatedAtFieldsToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :goal_1_updated_at, :datetime
    add_column :kids, :goal_2_updated_at, :datetime
  end
end
