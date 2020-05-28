class AddCoordsToKids < ActiveRecord::Migration[6.0]
  def change
    add_column :kids, :latitude, :float
    add_column :kids, :longitude, :float
  end
end
