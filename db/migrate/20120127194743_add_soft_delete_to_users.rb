class AddSoftDeleteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :inactive, :boolean, default: false
    add_index :users, :inactive
    add_column :kids, :inactive, :boolean, default: false
    add_index :kids, :inactive
  end
end
