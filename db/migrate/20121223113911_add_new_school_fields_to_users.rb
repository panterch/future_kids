class AddNewSchoolFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :college, :string
    add_column :users, :school_id, :integer
  end
end
