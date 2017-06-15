class AddDobToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :dob, :date
  end
end
