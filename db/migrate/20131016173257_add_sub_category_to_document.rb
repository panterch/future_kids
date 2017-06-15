class AddSubCategoryToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :subcategory, :string
  end
end
