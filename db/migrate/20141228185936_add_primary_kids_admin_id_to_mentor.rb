class AddPrimaryKidsAdminIdToMentor < ActiveRecord::Migration
  def change
    add_column :users, :primary_kids_admin_id, :integer
  end
end
