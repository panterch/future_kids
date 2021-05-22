class AddRegistrationStateToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :state, :string, default: 'confirmed'
  end
end
