class CreateSubstitutions < ActiveRecord::Migration
  def change
    create_table :substitutions do |t|
      t.date :start_at, null: false
      t.date :end_at, null: false

      t.timestamps null: false

      t.belongs_to :mentor, index: true
    end
  end
end
