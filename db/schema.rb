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

ActiveRecord::Schema.define(version: 20151026082645) do

  create_table "tiles", force: :cascade do |t|
    t.integer  "xcoord"
    t.integer  "ycoord"
    t.integer  "tiletype"
    t.string   "desc"
    t.string   "exits",      default: "--- {}\n"
    t.string   "backpack",   default: "--- []\n"
    t.string   "npcs",       default: "--- []\n"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "backpack",               default: "--- []\n"
    t.boolean  "admin",                  default: false
    t.integer  "tile_id"
    t.integer  "hp",                     default: 100
    t.string   "equipment",              default: "---\n:weapon: \n:chest: \n:legs: \n:arms: \n:helm: \n"
    t.datetime "created_at",                                                                               null: false
    t.datetime "updated_at",                                                                               null: false
    t.string   "email",                  default: "",                                                      null: false
    t.string   "encrypted_password",     default: "",                                                      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                                                       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
