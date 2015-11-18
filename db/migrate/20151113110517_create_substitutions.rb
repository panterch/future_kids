class CreateSubstitutions < ActiveRecord::Migration
  def change
    create_table :substitutions do |t|
      t.date :start_at, null: false
      t.date :end_at, null: false

      t.timestamps null: false
    end
  end
end
