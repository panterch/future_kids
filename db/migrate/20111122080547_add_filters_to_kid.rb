class AddFiltersToKid < ActiveRecord::Migration
  def change
    add_column :kids, :school, :string
    add_column :kids, :term, :string
  end
end
