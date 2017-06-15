class AddCategoryToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :category, :string
  end
end
