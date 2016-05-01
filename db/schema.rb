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

ActiveRecord::Schema.define(version: 20160501180228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "occurred_at"
  end

  add_index "actions", ["occurred_at"], name: "index_actions_on_occurred_at", using: :btree
  add_index "actions", ["user_id"], name: "index_actions_on_user_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "ancestry"
    t.integer  "user_id"
    t.boolean  "archived"
    t.integer  "order",        default: 0
    t.string   "color"
    t.datetime "completed_at"
    t.datetime "deleted_at"
  end

  add_index "items", ["ancestry"], name: "index_items_on_ancestry", using: :btree
  add_index "items", ["archived"], name: "index_items_on_archived", using: :btree
  add_index "items", ["completed_at"], name: "index_items_on_completed_at", using: :btree
  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.string   "image"
    t.datetime "last_visited_at"
    t.integer  "request_count"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end
