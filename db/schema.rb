# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110211123618) do

  create_table "journals", :force => true do |t|
    t.date     "held_at"
    t.time     "start_at"
    t.time     "end_at"
    t.string   "title"
    t.text     "body"
    t.text     "goal"
    t.text     "subject"
    t.text     "method"
    t.text     "outcome"
    t.integer  "kid_id"
    t.integer  "mentor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kids", :force => true do |t|
    t.string   "name"
    t.string   "prename"
    t.string   "parent"
    t.string   "address"
    t.string   "sex"
    t.string   "grade"
    t.string   "goal"
    t.date     "entered_at"
    t.integer  "mentor_id"
    t.integer  "secondary_mentor_id"
    t.integer  "teacher_id"
    t.integer  "secondary_teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.date     "held_at"
    t.string   "kind"
    t.text     "reason"
    t.text     "content"
    t.text     "outcome"
    t.text     "note"
    t.text     "attendee"
    t.integer  "kid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "prename"
    t.string   "address"
    t.string   "phone"
    t.string   "personnel_number"
    t.string   "field_of_study"
    t.string   "education"
    t.boolean  "etcs"
    t.date     "entry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

end
