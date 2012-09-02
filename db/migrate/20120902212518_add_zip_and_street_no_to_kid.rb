class AddZipAndStreetNoToKid < ActiveRecord::Migration
  def change
    add_column :kids, :zip, :string
    add_column :kids, :street_no, :string
  end
end
