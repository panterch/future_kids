class CreateSubstitutions < ActiveRecord::Migration[4.2]
  def change
    create_table :substitutions do |t|
      t.date :start_at, null: false
      t.date :end_at, null: false
      t.boolean :inactive, null: false, default: false

      t.timestamps null: false

      t.belongs_to :mentor, index: true
      # constraint
      t.belongs_to :secondary_mentor, class_name: 'Mentor', index: true
      t.belongs_to :kid, index: true
    end
  end
end
