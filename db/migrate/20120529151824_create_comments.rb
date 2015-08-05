class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :journal_id, null: false
      t.string :by, null: false
      t.text :body, null: false

      t.timestamps null: false
    end
  end
end
