class AddSubCategoryToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :subcategory, :string
  end
end
