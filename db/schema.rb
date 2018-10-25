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

ActiveRecord::Schema.define(version: 20181025154532) do

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "commenter"
    t.text "body"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "logged_labors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "task_id"
    t.bigint "user_id"
    t.decimal "time_spent", precision: 10, scale: 2
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_logged_labors_on_task_id"
    t.index ["user_id"], name: "index_logged_labors_on_user_id"
  end

  create_table "task_assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "task_id"
    t.bigint "assigned_to_id"
    t.bigint "assigned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_task_assignments_on_assigned_by_id"
    t.index ["assigned_to_id"], name: "index_task_assignments_on_assigned_to_id"
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
  end

  create_table "task_type_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.boolean "can_view"
    t.boolean "can_create"
    t.boolean "can_update"
    t.boolean "can_delete"
    t.boolean "can_approve"
    t.boolean "can_verify"
    t.boolean "can_comment"
    t.boolean "can_log_labor"
    t.boolean "can_view_cost"
    t.bigint "task_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_type_id"], name: "index_task_type_options_on_task_type_id"
  end

  create_table "task_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.integer "status"
    t.integer "percentComplete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_types_id"
    t.index ["task_types_id"], name: "index_tasks_on_task_types_id"
  end

  create_table "user_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "task_type_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_type_option_id"], name: "index_user_groups_on_task_type_option_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "employee_number"
    t.string "f_name"
    t.string "l_name"
    t.string "email"
    t.integer "hourly_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  add_foreign_key "comments", "tasks"
  add_foreign_key "logged_labors", "tasks"
  add_foreign_key "logged_labors", "users"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users", column: "assigned_by_id"
  add_foreign_key "task_assignments", "users", column: "assigned_to_id"
  add_foreign_key "task_type_options", "task_types"
end
