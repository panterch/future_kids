class AddThemesToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :title, :string
    add_column :sites, :css, :text
  end
end
