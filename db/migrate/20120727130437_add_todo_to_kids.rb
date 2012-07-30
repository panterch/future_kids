class AddTodoToKids < ActiveRecord::Migration
  def change
    add_column :kids, :todo, :text
  end
end
