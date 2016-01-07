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

ActiveRecord::Schema.define(version: 20160107030149) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "average_caches", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "avg",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "challenge_id"
  end

  add_index "categories", ["challenge_id"], name: "index_categories_on_challenge_id", using: :btree

  create_table "challenges", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "images"
    t.integer  "category_id"
  end

  add_index "challenges", ["category_id"], name: "index_challenges_on_category_id", using: :btree
  add_index "challenges", ["user_id"], name: "index_challenges_on_user_id", using: :btree

  create_table "overall_averages", force: :cascade do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "overall_avg",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "challenge_id"
    t.string   "images"
    t.text     "comments"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "posts", ["challenge_id"], name: "index_posts_on_challenge_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "rates", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.float    "stars",         null: false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], name: "index_rates_on_rateable_id_and_rateable_type", using: :btree
  add_index "rates", ["rater_id"], name: "index_rates_on_rater_id", using: :btree

  create_table "rating_caches", force: :cascade do |t|
    t.integer  "cacheable_id"
    t.string   "cacheable_type"
    t.float    "avg",            null: false
    t.integer  "qty",            null: false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rating_caches", ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",           default: false
    t.string   "images"
  end

  create_table "users_challenges", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "challenge_id"
    t.boolean  "completed"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "users_challenges", ["challenge_id"], name: "index_users_challenges_on_challenge_id", using: :btree
  add_index "users_challenges", ["user_id"], name: "index_users_challenges_on_user_id", using: :btree

  add_foreign_key "categories", "challenges"
  add_foreign_key "challenges", "categories"
  add_foreign_key "posts", "challenges"
  add_foreign_key "posts", "users"
  add_foreign_key "users_challenges", "challenges"
  add_foreign_key "users_challenges", "users"
end
