class AddImportantToJournals < ActiveRecord::Migration[4.2]
  def change
    add_column :journals, :important, :boolean, null: false, default: false
  end
end
