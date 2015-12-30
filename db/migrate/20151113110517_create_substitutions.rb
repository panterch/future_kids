class CreateSubstitutions < ActiveRecord::Migration
  def change
    create_table :substitutions do |t|
      t.date :start_at, null: false
      t.date :end_at, null: false
      t.boolean :closed, null: false, default: false

      t.timestamps null: false

      t.belongs_to :mentor, index: true
      # constraint
      t.belongs_to :secondary_mentor, class_name: 'Mentor', index: true
      t.belongs_to :kid, index: true
    end
  end
end
