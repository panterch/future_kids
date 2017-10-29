class AddCategoriesToDocuments < ActiveRecord::Migration[5.1]
  def change
    rename_column :documents, :category, :category0
    rename_column :documents, :subcategory, :category1
    add_column :documents, :category2, :string
    add_column :documents, :category3, :string
  end

end
