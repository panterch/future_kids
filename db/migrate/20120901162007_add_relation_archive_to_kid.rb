class AddRelationArchiveToKid < ActiveRecord::Migration
  def change
    add_column :kids, :relation_archive, :text
  end
end
