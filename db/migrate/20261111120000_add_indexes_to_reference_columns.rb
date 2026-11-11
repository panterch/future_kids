# frozen_string_literal: true

# The reference columns that had no index: looking up a person's kids or a
# journal's comments by them read the whole table.
#
# Left out on purpose: schools.principal_id (no code uses the column) and
# active_storage_attachments.record_id (covered by Active Storage's own index
# on record_type, record_id, name, blob_id)
class AddIndexesToReferenceColumns < ActiveRecord::Migration[8.1]
  def change
    add_index :comments, :journal_id
    add_index :comments, :created_by_id

    add_index :first_year_assessments, :teacher_id
    add_index :first_year_assessments, :mentor_id
    add_index :first_year_assessments, :created_by_id

    add_index :kids, :mentor_id
    add_index :kids, :secondary_mentor_id
    add_index :kids, :teacher_id
    add_index :kids, :secondary_teacher_id
    add_index :kids, :third_teacher_id
    add_index :kids, :admin_id

    add_index :principal_school_relations, :principal_id
    add_index :principal_school_relations, :school_id

    add_index :termination_assessments, :teacher_id
    add_index :termination_assessments, :created_by_id
  end
end
