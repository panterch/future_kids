class AddReceiveJournalsToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_journals, :boolean, default: false
  end
end
