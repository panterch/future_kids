# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140530141910) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "journal_id",                           null: false
    t.string   "by",                                   null: false
    t.text     "body",                                 null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "to_teacher",           default: false
    t.boolean  "to_secondary_teacher", default: false
  end

  create_table "documents", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "category"
    t.string   "subcategory"
  end

  create_table "journals", force: true do |t|
    t.date     "held_at",                    null: false
    t.time     "start_at"
    t.time     "end_at"
    t.integer  "duration",                   null: false
    t.integer  "week",                       null: false
    t.integer  "year",                       null: false
    t.boolean  "cancelled",  default: false, null: false
    t.text     "goal"
    t.text     "subject"
    t.text     "method"
    t.text     "outcome"
    t.text     "note"
    t.integer  "kid_id",                     null: false
    t.integer  "mentor_id",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "month"
  end

  add_index "journals", ["held_at"], name: "index_journals_on_held_at", using: :btree
  add_index "journals", ["kid_id"], name: "index_journals_on_kid_id", using: :btree
  add_index "journals", ["mentor_id"], name: "index_journals_on_mentor_id", using: :btree
  add_index "journals", ["month"], name: "index_journals_on_month", using: :btree

  create_table "kids", force: true do |t|
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
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "phone"
    t.boolean  "secondary_active",        default: false, null: false
    t.date     "dob"
    t.string   "language"
    t.boolean  "translator"
    t.text     "goal_1"
    t.text     "goal_2"
    t.text     "note"
    t.string   "city"
    t.string   "term"
    t.boolean  "inactive",                default: false
    t.text     "todo"
    t.text     "relation_archive"
    t.string   "zip"
    t.string   "street_no"
    t.date     "checked_at"
    t.date     "coached_at"
    t.text     "abnormality"
    t.integer  "abnormality_criticality"
    t.integer  "admin_id"
    t.integer  "school_id"
    t.string   "exit"
    t.string   "exit_reason"
  end

  add_index "kids", ["inactive"], name: "index_kids_on_inactive", using: :btree
  add_index "kids", ["school_id"], name: "index_kids_on_school_id", using: :btree

  create_table "relation_logs", force: true do |t|
    t.integer  "kid_id",     null: false
    t.integer  "user_id",    null: false
    t.string   "role"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "relation_logs", ["kid_id"], name: "index_relation_logs_on_kid_id", using: :btree
  add_index "relation_logs", ["user_id"], name: "index_relation_logs_on_user_id", using: :btree

  create_table "reminders", force: true do |t|
    t.date     "held_at",             null: false
    t.string   "recipient",           null: false
    t.integer  "week",                null: false
    t.integer  "year",                null: false
    t.integer  "kid_id",              null: false
    t.integer  "mentor_id",           null: false
    t.datetime "sent_at"
    t.integer  "secondary_mentor_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "acknowledged_at"
  end

  add_index "reminders", ["kid_id"], name: "index_reminders_on_kid_id", using: :btree
  add_index "reminders", ["mentor_id"], name: "index_reminders_on_mentor_id", using: :btree
  add_index "reminders", ["secondary_mentor_id"], name: "index_reminders_on_secondary_mentor_id", using: :btree
  add_index "reminders", ["sent_at"], name: "index_reminders_on_sent_at", using: :btree

  create_table "reviews", force: true do |t|
    t.date     "held_at"
    t.string   "kind"
    t.text     "reason"
    t.text     "content"
    t.text     "outcome"
    t.text     "note"
    t.text     "attendee"
    t.integer  "kid_id",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reviews", ["held_at"], name: "index_reviews_on_held_at", using: :btree
  add_index "reviews", ["kid_id"], name: "index_reviews_on_kid_id", using: :btree

  create_table "schedules", force: true do |t|
    t.integer  "person_id",   null: false
    t.string   "person_type", null: false
    t.integer  "day",         null: false
    t.integer  "hour",        null: false
    t.integer  "minute",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "schedules", ["person_id", "person_type", "day", "hour", "minute"], name: "index_schedules_on_uniqueness", unique: true, using: :btree

  create_table "schools", force: true do |t|
    t.string   "name"
    t.integer  "principal_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "street"
    t.string   "street_no"
    t.string   "zip"
    t.string   "city"
    t.string   "phone"
    t.string   "homepage",     default: "http://"
    t.string   "social"
    t.string   "district"
    t.string   "term"
    t.text     "note"
  end

  create_table "users", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "prename"
    t.string   "address"
    t.string   "phone"
    t.string   "personnel_number"
    t.string   "field_of_study"
    t.string   "education"
    t.text     "available"
    t.boolean  "ects"
    t.date     "entry_date"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "email",                                default: "",    null: false
    t.string   "encrypted_password",       limit: 128, default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "absence"
    t.string   "city"
    t.string   "transport"
    t.string   "term"
    t.date     "dob"
    t.boolean  "inactive",                             default: false
    t.text     "todo"
    t.boolean  "substitute",                           default: false
    t.string   "zip"
    t.string   "street_no"
    t.integer  "primary_kids_school_id"
    t.string   "college"
    t.integer  "school_id"
    t.text     "note"
    t.integer  "primary_kids_meeting_day"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["inactive"], name: "index_users_on_inactive", using: :btree

end
