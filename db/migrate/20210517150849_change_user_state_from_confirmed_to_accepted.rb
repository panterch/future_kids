class ChangeUserStateFromConfirmedToAccepted < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:users, :state, 'accepted')
    execute("UPDATE users SET state = 'accepted';")
  end
end
