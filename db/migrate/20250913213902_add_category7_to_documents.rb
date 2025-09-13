class AddCategory7ToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :category7, :string
  end
end
