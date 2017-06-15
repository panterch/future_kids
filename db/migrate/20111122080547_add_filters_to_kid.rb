class AddFiltersToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :school, :string
    add_column :kids, :term, :string
  end
end
