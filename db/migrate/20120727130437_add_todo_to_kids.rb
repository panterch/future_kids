class AddTodoToKids < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :todo, :text
  end
end
