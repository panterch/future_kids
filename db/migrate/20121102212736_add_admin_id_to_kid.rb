class AddAdminIdToKid < ActiveRecord::Migration
  def change
    add_column :kids, :admin_id, :integer
  end
end
