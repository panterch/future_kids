class RemovePrimaryKidsAdminIdFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :primary_kids_admin_id, :integer
  end
end
