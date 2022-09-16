class AddGoalsChangedAddToKids < ActiveRecord::Migration[6.1]
  def change
    add_column :kids, :goals_updated_at, :datetime
    remove_column :kids, :goal_1_updated_at, :datetime
    remove_column :kids, :goal_2_updated_at, :datetime
  end
end
