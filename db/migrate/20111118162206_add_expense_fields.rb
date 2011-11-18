class AddExpenseFields < ActiveRecord::Migration
  def up
    add_column :kids, :city, :string
    add_column :users, :city, :string
    add_column :users, :transport, :string
  end

  def down
    remove_column :kids, :city
    remove_column :users, :city
    remove_column :users, :transport
    
  end
end
