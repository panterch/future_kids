class AddZipAndStreetNoToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :zip, :string
    add_column :kids, :street_no, :string
  end
end
