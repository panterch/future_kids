class AddSchoolKindToSchools < ActiveRecord::Migration[6.0]

  def up
    execute <<-SQL
      CREATE TYPE school_kind AS ENUM ('high_school', 'gymnasium', 'secondary_school', 'primary_school');
    SQL
    add_column :schools, :school_kind, :school_kind
    add_index :schools, :school_kind
  end

  def down
    remove_index :schools, name: 'index_schools_on_school_kind'
    remove_column :schools, :school_kind
    execute <<-SQL
      DROP TYPE school_kind;
    SQL
  end
end
