class CreateFirstYearAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :first_year_assessments do |t|
      t.references :kid, foreign_key: true, null: false
      t.integer :teacher_id, null: false
      t.integer :mentor_id, null: false
      t.integer :created_by_id

      t.date :held_at
      t.integer :duration
      t.text :development_teacher
      t.text :development_mentor
      t.text :goals_teacher
      t.text :goals_mentor
      t.text :relation_mentor
      t.text :motivation
      t.text :collaboration
      t.boolean :breaking_off
      t.text :breaking_reason
      t.text :goal_1
      t.text :goal_2
      t.text :goal_3
      t.text :improvements
      t.boolean :mentor_stays
      t.text :note

      t.timestamps
    end
  end
end
