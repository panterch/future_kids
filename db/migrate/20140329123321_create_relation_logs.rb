class CreateRelationLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :relation_logs do |t|
      t.integer :kid_id, null: false
      t.integer :user_id, null: false
      t.string :role
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps null: false
    end

    add_index :relation_logs, :kid_id
    add_index :relation_logs, :user_id
  end
end
