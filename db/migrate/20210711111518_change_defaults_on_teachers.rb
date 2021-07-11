class ChangeDefaultsOnTeachers < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:users, :receive_journals, true)
  end
end
