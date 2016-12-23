class RemovePrimaryKidsAdminIdFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :primary_kids_admin_id, :integer
  end
end
