class AddExitToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :exit, :string
  end
end
