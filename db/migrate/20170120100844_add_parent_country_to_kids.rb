class AddParentCountryToKids < ActiveRecord::Migration
  def change
    add_column :kids, :parent_country, :string
  end
end
