class CreateInititalTables < ActiveRecord::Migration
  def self.up
    create_table :kids do |t|
      t.string :name
      t.string :prename
      t.string :parent
      t.string :address
      t.string :sex
      t.string :grade
      t.string :goal
      t.text :available
      t.date :entered_at, type: Date
      t.integer :meeting_day
      t.time :meeting_start_at
      t.references :mentor
      t.integer :secondary_mentor_id
      t.references :teacher
      t.integer :secondary_teacher_id
      t.timestamps null: false
    end

    create_table :journals do |t|
      t.date :held_at, null: false
      t.time :start_at
      t.time :end_at
      t.integer :duration, null: false
      t.integer :week, null: false
      t.integer :year, null: false
      t.boolean :cancelled, null: false, default: false
      t.text :goal
      t.text :subject
      t.text :method
      t.text :outcome
      t.text :note
      t.integer :kid_id, null: false
      t.integer :mentor_id, null: false
      t.timestamps null: false
    end

    add_index(:journals, :kid_id)
    add_index(:journals, :mentor_id)
    add_index(:journals, :held_at)

    create_table :reviews do |t|
      t.date :held_at
      t.string :kind
      t.text :reason
      t.text :content
      t.text :outcome
      t.text :note
      t.text :outcome
      t.text :attendee
      t.references :kid, null: false
      t.timestamps null: false
    end

    add_index(:reviews, :kid_id)
    add_index(:reviews, :held_at)

    create_table :users do |t|
      t.string :type
      t.string :name
      t.string :prename
      t.string :address
      t.string :phone
      t.string :personnel_number
      t.string :field_of_study
      t.string :education
      t.string :school
      t.text :available
      t.boolean :etcs
      t.date :entry_date
      t.timestamps null: false
      t.string 'email',                                   default: '',    null: false
      t.string 'encrypted_password',       limit: 128, default: '',    null: false
      t.string 'reset_password_token'
      t.datetime 'reset_password_sent_at'
      t.datetime 'remember_created_at'
      t.integer 'sign_in_count',                           default: 0
      t.datetime 'current_sign_in_at'
      t.datetime 'last_sign_in_at'
      t.string 'current_sign_in_ip'
      t.string 'last_sign_in_ip'
    end

    add_index(:users, :email)

    create_table :reminders do |t|
      t.date :held_at, null: false
      t.string :recipient, null: false
      t.integer :week, null: false
      t.integer :year, null: false
      t.integer :kid_id, null: false
      t.integer :mentor_id, null: false
      t.timestamp :sent_at
      t.integer :secondary_mentor_id
      t.timestamps null: false
    end

    add_index(:reminders, :sent_at)
    add_index(:reminders, :kid_id)
    add_index(:reminders, :mentor_id)
    add_index(:reminders, :secondary_mentor_id)
  end

  def self.down
    drop_table :kids
    drop_table :journals
    drop_table :reviews
    drop_table :users
    drop_table :reminders
  end
end
