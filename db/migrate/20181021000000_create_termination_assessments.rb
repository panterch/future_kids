class CreateTerminationAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :termination_assessments do |t|
      t.references :kid, foreign_key: true, null: false
      t.integer :teacher_id, null: false
      t.integer :created_by_id, null: false

      t.date :held_at
      t.text :development
      t.text :goals
      t.text :goals_reached
      t.text :note
      t.text :improvements
      t.text :collaboration

      t.timestamps
    end
  end
end
