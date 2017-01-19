class AddImportantToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :important, :boolean, null: false, default: false
  end
end
