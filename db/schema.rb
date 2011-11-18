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

ActiveRecord::Schema.define(:version => 20111118162206) do

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.date     "held_at",                       :null => false
    t.time     "start_at"
    t.time     "end_at"
    t.integer  "duration",                      :null => false
    t.integer  "week",                          :null => false
    t.integer  "year",                          :null => false
    t.boolean  "cancelled",  :default => false, :null => false
    t.text     "goal"
    t.text     "subject"
    t.text     "method"
    t.text     "outcome"
    t.text     "note"
    t.integer  "kid_id",                        :null => false
    t.integer  "mentor_id",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "month"
  end

  add_index "journals", ["held_at"], :name => "index_journals_on_held_at"
  add_index "journals", ["kid_id"], :name => "index_journals_on_kid_id"
  add_index "journals", ["mentor_id"], :name => "index_journals_on_mentor_id"
  add_index "journals", ["month"], :name => "index_journals_on_month"

  create_table "kids", :force => true do |t|
    t.string   "name"
    t.string   "prename"
    t.string   "parent"
    t.string   "address"
    t.string   "sex"
    t.string   "grade"
    t.text     "available"
    t.date     "entered_at"
    t.integer  "meeting_day"
    t.time     "meeting_start_at"
    t.integer  "mentor_id"
    t.integer  "secondary_mentor_id"
    t.integer  "teacher_id"
    t.integer  "secondary_teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.boolean  "secondary_active",     :default => false, :null => false
    t.date     "dob"
    t.string   "language"
    t.boolean  "translator"
    t.text     "goal_1"
    t.text     "goal_2"
    t.text     "note"
    t.string   "city"
  end

  create_table "reminders", :force => true do |t|
    t.date     "held_at",             :null => false
    t.string   "recipient",           :null => false
    t.integer  "week",                :null => false
    t.integer  "year",                :null => false
    t.integer  "kid_id",              :null => false
    t.integer  "mentor_id",           :null => false
    t.datetime "sent_at"
    t.integer  "secondary_mentor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "acknowledged_at"
  end

  add_index "reminders", ["kid_id"], :name => "index_reminders_on_kid_id"
  add_index "reminders", ["mentor_id"], :name => "index_reminders_on_mentor_id"
  add_index "reminders", ["secondary_mentor_id"], :name => "index_reminders_on_secondary_mentor_id"
  add_index "reminders", ["sent_at"], :name => "index_reminders_on_sent_at"

  create_table "reviews", :force => true do |t|
    t.date     "held_at"
    t.string   "kind"
    t.text     "reason"
    t.text     "content"
    t.text     "outcome"
    t.text     "note"
    t.text     "attendee"
    t.integer  "kid_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["held_at"], :name => "index_reviews_on_held_at"
  add_index "reviews", ["kid_id"], :name => "index_reviews_on_kid_id"

  create_table "schedules", :force => true do |t|
    t.integer  "person_id",   :null => false
    t.string   "person_type", :null => false
    t.integer  "day",         :null => false
    t.integer  "hour",        :null => false
    t.integer  "minute",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["person_id", "person_type", "day", "hour", "minute"], :name => "index_schedules_on_uniqueness", :unique => true

  create_table "users", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "prename"
    t.string   "address"
    t.string   "phone"
    t.string   "personnel_number"
    t.string   "field_of_study"
    t.string   "education"
    t.string   "school"
    t.text     "available"
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
    t.text     "absence"
    t.string   "city"
    t.string   "transport"
  end

  add_index "users", ["email"], :name => "index_users_on_email"

end
