class AddMoreCategoriesToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :category4, :string
    add_column :documents, :category5, :string
    add_column :documents, :category6, :string
  end

end
