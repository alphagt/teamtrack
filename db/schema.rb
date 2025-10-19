# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_10_19_232455) do
  create_table "accounts", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "primary_admin_id"
    t.integer "secondary_admin_id"
    t.boolean "active", default: true
    t.date "termdate"
    t.integer "userquota"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "active_storage_attachments", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.boolean "is_fixed"
    t.decimal "effort", precision: 2, scale: 1
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "set_period_id", precision: 6, scale: 2
    t.integer "tech_sys_id", default: 0
    t.integer "initiative_id", default: 0
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["set_period_id"], name: "index_assignments_on_set_period_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "initiatives", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "fiscal"
    t.string "name"
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tag"
    t.string "subprilist"
    t.integer "account_id", default: 0
    t.index ["account_id"], name: "index_initiatives_on_account_id"
    t.index ["active"], name: "index_initiatives_on_active"
  end

  create_table "invite_codes", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.string "code"
    t.datetime "expire", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "note"
    t.index ["account_id"], name: "index_invite_codes_on_account_id"
  end

  create_table "projects", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.integer "owner_id"
    t.string "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "fixed_resource_budget"
    t.string "category", default: "Unassigned"
    t.integer "upl_number", default: 0
    t.string "tribe", default: "NA"
    t.integer "initiative_id"
    t.boolean "keyproj"
    t.string "rtm", default: "NA"
    t.string "psh", default: "NA"
    t.string "ctpriority", default: "NA"
    t.integer "account_id", default: 0
    t.datetime "end_date", precision: nil
    t.string "fin_type", default: "Undefined"
    t.index ["account_id", "upl_number"], name: "index_projects_on_account_id_and_upl_number", unique: true
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["active"], name: "index_projects_on_active"
    t.index ["category"], name: "index_projects_on_category"
    t.index ["initiative_id"], name: "index_projects_on_initiative_id"
    t.index ["name"], name: "index_projects_on_name"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
  end

  create_table "set_periods", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "fiscal_year"
    t.integer "week_number"
    t.integer "cweek_offset"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "settings", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.integer "ordinal"
    t.string "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "displayname"
    t.string "description"
    t.integer "stype"
    t.integer "account_id"
  end

  create_table "tech_systems", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "qos_group"
    t.integer "owner_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_tech_systems_on_account_id"
    t.index ["owner_id"], name: "index_tech_systems_on_owner_id"
    t.index ["qos_group"], name: "index_tech_systems_on_qos_group"
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.integer "primary_account_id", default: -1
    t.text "account_list"
    t.string "slackid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["ismanager"], name: "index_users_on_ismanager"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["org"], name: "index_users_on_org"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "invite_codes", "accounts"
  add_foreign_key "projects", "initiatives"
end
