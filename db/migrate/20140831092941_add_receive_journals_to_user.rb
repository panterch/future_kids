class AddReceiveJournalsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :receive_journals, :boolean, default: false
  end
end
