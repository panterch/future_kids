class AddAdminOnlyToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :admin_only, :boolean, null: false, default: false
  end
end 