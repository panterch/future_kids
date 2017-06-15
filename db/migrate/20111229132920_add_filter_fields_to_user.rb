class AddFilterFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :term, :string
    add_column :users, :primary_kids_school, :string
  end
end
