class AddZipAndStreetNoToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :zip, :string
    add_column :users, :street_no, :string
  end
end
