class CreateSite < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :footer_address
      t.string :footer_email
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.boolean :feature_coach, default: true
    end
  end
end
