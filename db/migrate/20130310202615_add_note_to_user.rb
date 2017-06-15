class AddNoteToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :note, :text
  end
end
