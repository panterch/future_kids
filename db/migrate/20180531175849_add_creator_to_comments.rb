class AddCreatorToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :created_by_id, :integer
  end
end
