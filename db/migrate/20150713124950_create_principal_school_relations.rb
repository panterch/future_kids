class CreatePrincipalSchoolRelations < ActiveRecord::Migration
  def up
    create_table :principal_school_relations do |t|
      t.integer :principal_id
      t.integer :school_id

      t.timestamps null: false
    end

    Principal.all.each do |principal|
    	PrincipalSchoolRelation.create principal_id: principal.id, school_id: principal.school.id
    end
  end

  def down
  	drop_table :principal_school_relations
  end
end
