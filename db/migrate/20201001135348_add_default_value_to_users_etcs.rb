class AddDefaultValueToUsersEtcs < ActiveRecord::Migration[6.0]
  def up
    User.where('ects is NULL').update_all(ects: false)
    change_column :users, :ects, :boolean, null: false, default: false
  end

  def down
    change_column :users, :ects, :boolean, null: true, default: nil
  end

end
