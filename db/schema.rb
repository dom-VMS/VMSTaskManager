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

ActiveRecord::Schema.define(version: 2019_05_15_183556) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attachments"
    t.bigint "commenter_id"
    t.index ["commenter_id"], name: "index_comments_on_commenter_id"
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "logged_labors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "user_id"
    t.decimal "time_spent", precision: 10, scale: 2
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "labor_date"
    t.index ["task_id"], name: "index_logged_labors_on_task_id"
    t.index ["user_id"], name: "index_logged_labors_on_user_id"
  end

  create_table "reoccuring_task_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reoccuring_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "reoccuring_task_type_id"
    t.bigint "task_id"
    t.integer "freq_days"
    t.datetime "last_date"
    t.datetime "next_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "freq_weeks"
    t.integer "freq_months"
    t.index ["reoccuring_task_type_id"], name: "index_reoccuring_tasks_on_reoccuring_task_type_id"
    t.index ["task_id"], name: "index_reoccuring_tasks_on_task_id"
  end

  create_table "task_assignments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "assigned_to_id"
    t.bigint "assigned_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_task_assignments_on_assigned_by_id"
    t.index ["assigned_to_id"], name: "index_task_assignments_on_assigned_to_id"
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
  end

  create_table "task_queues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "user_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_type_id"
    t.index ["task_id"], name: "index_task_queues_on_task_id"
    t.index ["task_type_id"], name: "index_task_queues_on_task_type_id"
    t.index ["user_id"], name: "index_task_queues_on_user_id"
  end

  create_table "task_type_options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.boolean "isAdmin"
    t.index ["task_type_id"], name: "index_task_type_options_on_task_type_id"
  end

  create_table "task_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_task_types_on_parent_id"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.integer "status"
    t.integer "percentComplete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "task_type_id"
    t.boolean "isApproved"
    t.boolean "isVerified"
    t.bigint "created_by_id"
    t.json "attachments"
    t.datetime "due_date"
    t.boolean "verification_required"
    t.boolean "logged_labor_required"
    t.bigint "completed_by_id"
    t.bigint "verified_by_id"
    t.datetime "completed_date"
    t.index ["completed_by_id"], name: "index_tasks_on_completed_by_id"
    t.index ["created_by_id"], name: "index_tasks_on_created_by_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
    t.index ["verified_by_id"], name: "index_tasks_on_verified_by_id"
  end

  create_table "user_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "task_type_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_type_option_id"], name: "index_user_groups_on_task_type_option_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "employee_number"
    t.string "f_name"
    t.string "l_name"
    t.string "email"
    t.integer "hourly_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
  end

  add_foreign_key "comments", "tasks"
  add_foreign_key "comments", "users", column: "commenter_id"
  add_foreign_key "logged_labors", "tasks"
  add_foreign_key "logged_labors", "users"
  add_foreign_key "reoccuring_tasks", "reoccuring_task_types"
  add_foreign_key "reoccuring_tasks", "tasks"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users", column: "assigned_by_id"
  add_foreign_key "task_assignments", "users", column: "assigned_to_id"
  add_foreign_key "task_queues", "task_types"
  add_foreign_key "task_queues", "tasks"
  add_foreign_key "task_queues", "users"
  add_foreign_key "task_type_options", "task_types"
  add_foreign_key "task_types", "task_types", column: "parent_id"
  add_foreign_key "tasks", "users", column: "completed_by_id"
  add_foreign_key "tasks", "users", column: "created_by_id"
  add_foreign_key "tasks", "users", column: "verified_by_id"
end
