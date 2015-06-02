class AddTermCollectionFieldsToSite < ActiveRecord::Migration
  def change
    add_column :sites, :term_collection_start, :integer, default: 2014
    add_column :sites, :term_collection_end, :integer, default: 2020
  end
end
