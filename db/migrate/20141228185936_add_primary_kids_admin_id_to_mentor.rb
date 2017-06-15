class AddPrimaryKidsAdminIdToMentor < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :primary_kids_admin_id, :integer
  end
end
