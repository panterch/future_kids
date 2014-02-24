class AddExitToKid < ActiveRecord::Migration
  def change
    add_column :kids, :exit, :string
    add_column :kids, :exit_reason, :string
  end
end
