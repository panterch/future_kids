class AddTermsOfUseContentToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :terms_of_use_content, :text
    add_column :sites, :terms_of_use_content_parsed, :text
  end
end
