class ChangeAssessmentRelationsToNullable < ActiveRecord::Migration[6.1]
  def change
    change_column :first_year_assessments, :teacher_id, :integer, null: true
    change_column :first_year_assessments, :mentor_id, :integer, null: true
    change_column :termination_assessments, :teacher_id, :integer, null: true
  end
end
