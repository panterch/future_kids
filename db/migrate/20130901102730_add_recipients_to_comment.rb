class AddRecipientsToComment < ActiveRecord::Migration
  def change
    add_column :comments, :to_teacher, :boolean, :default => false
    add_column :comments, :to_secondary_teacher, :boolean, :default => false
  end
end
