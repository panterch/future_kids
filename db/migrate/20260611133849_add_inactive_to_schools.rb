class AddInactiveToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :inactive,    :boolean,  null: false, default: false
    add_column :schools, :inactive_at, :datetime
    add_index  :schools, :inactive
  end
end
