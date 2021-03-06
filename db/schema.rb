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

ActiveRecord::Schema.define(version: 20170625144120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "auctions", force: :cascade do |t|
    t.string   "name"
    t.string   "image_1"
    t.float    "start_price"
    t.float    "bet_price"
    t.float    "current_price", default: 0.0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "active",        default: false
    t.string   "image_2"
    t.hstore   "participants",  default: [],    null: false, array: true
    t.hstore   "history",       default: [],    null: false, array: true
    t.text     "description"
    t.float    "end_price"
    t.integer  "auction_time"
    t.integer  "receiver"
    t.string   "channel"
  end

  create_table "banned_users", force: :cascade do |t|
    t.string "user_id"
    t.string "first_name"
    t.string "last_name"
  end

  create_table "channels", force: :cascade do |t|
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "rules"
  end

  create_table "telegram_logs", force: :cascade do |t|
    t.string   "user"
    t.json     "data"
    t.string   "action"
    t.integer  "auction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_telegram_logs_on_auction_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "registration_code"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "telegram_logs", "auctions"
end
