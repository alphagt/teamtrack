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

ActiveRecord::Schema.define(version: 20171012013043) do

  create_table "assignments", force: :cascade do |t|
    t.boolean  "is_fixed"
    t.decimal  "effort",                  precision: 2, scale: 1
    t.integer  "user_id",       limit: 4
    t.integer  "project_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "set_period_id",           precision: 6, scale: 2
    t.integer  "tech_sys_id",   limit: 4,                         default: 0
  end

  add_index "assignments", ["project_id"], name: "index_assignments_on_project_id", using: :btree
  add_index "assignments", ["set_period_id"], name: "index_assignments_on_set_period_id", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "initiatives", force: :cascade do |t|
    t.integer  "fiscal",      limit: 4
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.boolean  "active",                  default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.boolean  "active"
    t.integer  "owner_id",              limit: 4
    t.string   "description",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fixed_resource_budget", limit: 4
    t.string   "category",              limit: 255, default: "Unassigned"
    t.integer  "upl_number",            limit: 4,   default: 0
    t.string   "tribe",                 limit: 255
    t.integer  "initiative_id",         limit: 4
  end

  add_index "projects", ["category"], name: "index_projects_on_category", using: :btree
  add_index "projects", ["initiative_id"], name: "index_projects_on_initiative_id", using: :btree

  create_table "set_periods", force: :cascade do |t|
    t.integer  "fiscal_year",  limit: 4
    t.integer  "week_number",  limit: 4
    t.integer  "cweek_offset", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tech_systems", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "qos_group",   limit: 255
    t.integer  "owner_id",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
    t.boolean  "admin"
    t.boolean  "ismanager",                          default: false
    t.integer  "manager_id",             limit: 4
    t.boolean  "verified",                           default: false
    t.boolean  "isstatususer",                       default: false
    t.integer  "impersonate_manager",    limit: 4,   default: 0
    t.integer  "default_system_id",      limit: 4
    t.boolean  "is_contractor"
    t.string   "org",                    limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["ismanager"], name: "index_users_on_ismanager", using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "projects", "initiatives"
end
