class AddZipAndStreetNoToUser < ActiveRecord::Migration
  def change
    add_column :users, :zip, :string
    add_column :users, :street_no, :string
  end
end
