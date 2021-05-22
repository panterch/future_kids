class AddInactiveAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :inactive_at, :datetime
  end
end
