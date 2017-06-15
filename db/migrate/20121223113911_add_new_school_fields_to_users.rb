class AddNewSchoolFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :college, :string
    add_column :users, :school_id, :integer
  end
end
