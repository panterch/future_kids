class AddFilterFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :term, :string
    add_column :users, :primary_kids_school, :string
  end
end
