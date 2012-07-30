class AddTodoToUser < ActiveRecord::Migration
  def change
    add_column :users, :todo, :text
  end
end
