class AddParentCountryToKids < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :parent_country, :string
  end
end
