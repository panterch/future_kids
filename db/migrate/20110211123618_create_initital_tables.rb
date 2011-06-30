class CreateInititalTables < ActiveRecord::Migration
  def self.up
    create_table :kids do |t|
      t.string     :name
      t.string     :prename
      t.string     :parent
      t.string     :address
      t.string     :sex
      t.string     :grade
      t.string     :goal
      t.date       :entered_at, :type => Date
      t.references :mentor
      t.integer    :secondary_mentor_id
      t.references :teacher
      t.integer    :secondary_teacher_id
      t.timestamps
    end

    create_table :journals do |t|
      t.date       :held_at, :null => false
      t.time       :start_at, :null => false
      t.time       :end_at, :null => false
      t.integer    :duration, :null => false
      t.string     :title
      t.text       :body
      t.text       :goal
      t.text       :subject
      t.text       :method
      t.text       :outcome
      t.integer    :kid_id, :null => false
      t.integer    :mentor_id, :null => false
      t.timestamps
    end

    create_table :reviews do |t|
      t.date       :held_at
      t.string     :kind
      t.text       :reason
      t.text       :content
      t.text       :outcome
      t.text       :note
      t.text       :outcome
      t.text       :attendee
      t.references :kid, :null => false
      t.timestamps
    end

    create_table :users do |t|
      t.string     :type
      t.string     :name
      t.string     :prename
      t.string     :address 
      t.string     :phone 
      t.string     :personnel_number 
      t.string     :field_of_study 
      t.string     :education 
      t.boolean    :etcs
      t.date       :entry_date
      t.timestamps

      t.database_authenticatable
      t.recoverable
      t.rememberable
      t.trackable
    end


    
  end

  def self.down
    drop_table :kids
    drop_table :journals
    drop_table :reviews
    drop_table :users
  end
end
