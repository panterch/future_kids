class AddTodoToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :todo, :text
  end
end
