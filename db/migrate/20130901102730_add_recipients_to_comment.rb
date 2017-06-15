class AddRecipientsToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :to_teacher, :boolean, default: false
    add_column :comments, :to_secondary_teacher, :boolean, default: false
  end
end
