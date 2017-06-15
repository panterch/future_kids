class AddExitFiledToKidsAndMentors < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :exit_kind, :string
    add_column :kids, :exit_at, :date
    add_column :users, :exit_kind, :string
    add_column :users, :exit_at, :date
  end
end
