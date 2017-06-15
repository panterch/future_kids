class AddAdminIdToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :admin_id, :integer
  end
end
