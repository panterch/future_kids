class AddDownloadCountToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :download_count, :integer, default: 0, null: false
  end
end
