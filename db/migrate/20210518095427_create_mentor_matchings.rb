class CreateMentorMatchings < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_matchings do |t|
      t.references :mentor, foreign_key: { to_table: :users }
      t.references :kid, foreign_key: true
      t.string :state, default: 'pending'
      t.text :message

      t.timestamps
    end
  end
end
