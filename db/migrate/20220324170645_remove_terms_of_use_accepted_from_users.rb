class RemoveTermsOfUseAcceptedFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :terms_of_use_accepted
  end
end
