class FixTermOfUseColumnDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :terms_of_use_accepted_at, DateTime.now
    change_column_default :sites, :terms_of_use_content_changed_at, DateTime.now
  end
end
