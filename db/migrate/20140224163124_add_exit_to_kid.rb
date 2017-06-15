class AddExitToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :exit, :string
    add_column :kids, :exit_reason, :string
  end
end
