class AddDefaultEMailToSite < ActiveRecord::Migration[6.0]
  def change
    add_column :sites, :notifications_default_email, :string
  end
end
