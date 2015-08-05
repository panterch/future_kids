class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :person_id, null: false
      t.string :person_type, null: false
      t.integer :day, null: false
      t.integer :hour, null: false
      t.integer :minute, null: false

      t.timestamps null: false
    end

    add_index(:schedules, [:person_id, :person_type, :day, :hour, :minute],
              unique: true, name: 'index_schedules_on_uniqueness')
  end

  def self.down
    drop_table :schedules
  end
end
