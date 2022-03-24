class FixTermOfUseColumnNames < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :terms_of_use_accepted_date, :terms_of_use_accepted_at
    rename_column :sites, :terms_of_use_changed_date, :terms_of_use_content_changed_at
  end
end
