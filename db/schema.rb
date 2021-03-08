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

ActiveRecord::Schema.define(version: 20210306040606) do

  create_table "accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "email"
    t.integer "primary_admin_id"
    t.integer "secondary_admin_id"
    t.boolean "active", default: true
    t.date "termdate"
    t.integer "userquota"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean "is_fixed"
    t.decimal "effort", precision: 2, scale: 1
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "set_period_id", precision: 6, scale: 2
    t.integer "tech_sys_id", default: 0
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["set_period_id"], name: "index_assignments_on_set_period_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "initiatives", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "fiscal"
    t.string "name"
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
    t.string "subprilist"
    t.index ["active"], name: "index_initiatives_on_active"
  end

  create_table "invite_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "account_id"
    t.string "code"
    t.datetime "expire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_invite_codes_on_account_id"
  end

  create_table "projects", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.boolean "active"
    t.integer "owner_id"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "fixed_resource_budget"
    t.string "category", default: "Unassigned"
    t.integer "upl_number", default: 0
    t.string "tribe", default: "NA"
    t.integer "initiative_id"
    t.boolean "keyproj"
    t.string "rtm", default: "NA"
    t.string "psh", default: "NA"
    t.string "ctpriority", default: "NA"
    t.index ["active"], name: "index_projects_on_active"
    t.index ["category"], name: "index_projects_on_category"
    t.index ["initiative_id"], name: "index_projects_on_initiative_id"
    t.index ["name"], name: "index_projects_on_name"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
    t.index ["upl_number"], name: "index_projects_on_upl_number", unique: true
  end

  create_table "set_periods", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "fiscal_year"
    t.integer "week_number"
    t.integer "cweek_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "key"
    t.integer "ordinal"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "displayname"
    t.string "description"
    t.integer "stype"
    t.integer "primary_account_id"
  end

  create_table "tech_systems", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "description"
    t.string "qos_group"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_tech_systems_on_owner_id"
    t.index ["qos_group"], name: "index_tech_systems_on_qos_group"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.boolean "admin"
    t.boolean "ismanager", default: false
    t.integer "manager_id"
    t.boolean "verified", default: false
    t.boolean "isstatususer", default: false
    t.integer "impersonate_manager", default: 0
    t.integer "default_system_id"
    t.boolean "is_contractor"
    t.string "org"
    t.boolean "orgowner"
    t.string "submgrs"
    t.string "etype"
    t.string "category"
    t.boolean "superadmin", default: false
    t.integer "primary_account_id", default: 0
    t.text "account_list"
    t.string "slackid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["ismanager"], name: "index_users_on_ismanager"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["org"], name: "index_users_on_org"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "invite_codes", "accounts"
  add_foreign_key "projects", "initiatives"
end
