class CreatePrincipalSchoolRelations < ActiveRecord::Migration[4.2]
  def up
    create_table :principal_school_relations do |t|
      t.integer :principal_id
      t.integer :school_id

      t.timestamps null: false
    end

    Principal.where.not(school_id: nil).each do |principal|
    	PrincipalSchoolRelation.create principal_id: principal.id, school_id: principal.school_id
    end
  end

  def down
  	drop_table :principal_school_relations
  end
end
