class AddSexToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sex, :string
  end
end
