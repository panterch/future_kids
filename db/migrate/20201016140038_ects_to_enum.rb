class EctsToEnum < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :ects, :ects_legacy
    add_column :users, :ects, :integer
  end
end
