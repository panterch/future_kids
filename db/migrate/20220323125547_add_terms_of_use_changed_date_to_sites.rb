class AddTermsOfUseChangedDateToSites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :terms_of_use_changed_date, :datetime
  end
end
