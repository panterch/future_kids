class AddExitKindUpdatedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :exit_kind_updated_at, :timestamp
  end
end
