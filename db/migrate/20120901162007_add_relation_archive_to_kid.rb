class AddRelationArchiveToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :relation_archive, :text
  end
end
