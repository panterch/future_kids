class AddSubstituteToUser < ActiveRecord::Migration
  def change
    add_column :users, :substitute, :boolean, default: false
  end
end
