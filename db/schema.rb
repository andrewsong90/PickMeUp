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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130507220835) do

  create_table "events", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "name"
    t.text     "description"
    t.string   "DateTime"
    t.string   "genre"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "organizer_id"
    t.string   "filepicker_url"
    t.string   "eventbrite_id"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "organizers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "affiliation"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "eventbrite_id"
  end

  create_table "pmus", :force => true do |t|
    t.integer  "owner_id"
    t.string   "datetime"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "pmu_type"
    t.boolean  "cab_sharing"
    t.boolean  "car_sharing"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "completed"
    t.integer  "max_people"
    t.integer  "event_id"
  end

  create_table "requesting_user_pmus", :force => true do |t|
    t.integer  "user_id"
    t.integer  "pmu_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tickets", :force => true do |t|
    t.string   "number"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "event_id"
    t.integer  "owner_id",   :default => -1
  end

  create_table "user_pmus", :force => true do |t|
    t.integer  "user_id"
    t.integer  "pmu_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "code"
    t.boolean  "confirmed"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "datetime"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "address"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "email"
    t.string   "gender"
    t.string   "phone"
  end

end
