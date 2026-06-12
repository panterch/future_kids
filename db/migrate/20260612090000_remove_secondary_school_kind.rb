class RemoveSecondarySchoolKind < ActiveRecord::Migration[8.0]
  def up
    # Migrate existing secondary_school records to primary_school
    execute "UPDATE schools SET school_kind = 'primary_school' WHERE school_kind = 'secondary_school'"

    # Remove the index before changing the column type
    remove_index :schools, name: 'index_schools_on_school_kind'

    # Change column to text temporarily so we can recreate the enum
    execute 'ALTER TABLE schools ALTER COLUMN school_kind TYPE text'

    # Recreate the enum without secondary_school
    execute "DROP TYPE school_kind"
    execute "CREATE TYPE school_kind AS ENUM ('high_school', 'gymnasium', 'primary_school')"

    # Change column back to the new enum type
    execute 'ALTER TABLE schools ALTER COLUMN school_kind TYPE school_kind USING school_kind::school_kind'

    add_index :schools, :school_kind
  end

  def down
    remove_index :schools, name: 'index_schools_on_school_kind'
    execute 'ALTER TABLE schools ALTER COLUMN school_kind TYPE text'
    execute 'DROP TYPE school_kind'
    execute "CREATE TYPE school_kind AS ENUM ('high_school', 'gymnasium', 'secondary_school', 'primary_school')"
    execute 'ALTER TABLE schools ALTER COLUMN school_kind TYPE school_kind USING school_kind::school_kind'
    add_index :schools, :school_kind
  end
end
