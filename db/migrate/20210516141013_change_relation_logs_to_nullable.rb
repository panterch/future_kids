class ChangeRelationLogsToNullable < ActiveRecord::Migration[6.1]
  def change
    change_column :relation_logs, :kid_id, :integer, null: true
    change_column :relation_logs, :user_id, :integer, null: true
  end
end
