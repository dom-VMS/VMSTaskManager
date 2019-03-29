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

ActiveRecord::Schema.define(version: 2019_03_26_190151) do

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
    t.string "commenter"
    t.text "body"
    t.bigint "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attachments"
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "file_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "comment_id"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_file_attachments_on_comment_id"
    t.index ["task_id"], name: "index_file_attachments_on_task_id"
  end

  create_table "logged_labors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.bigint "user_id"
    t.decimal "time_spent", precision: 10, scale: 2
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_logged_labors_on_task_id"
    t.index ["user_id"], name: "index_logged_labors_on_user_id"
  end

  create_table "reoccuring_event_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reoccuring_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "freq_days"
    t.date "last_date"
    t.date "next_date"
    t.bigint "task_id"
    t.bigint "reoccuring_event_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reoccuring_event_type_id"], name: "index_reoccuring_events_on_reoccuring_event_type_id"
    t.index ["task_id"], name: "index_reoccuring_events_on_task_id"
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
    t.bigint "reoccuring_event_id"
    t.json "attachments"
    t.datetime "due_date"
    t.index ["created_by_id"], name: "index_tasks_on_created_by_id"
    t.index ["reoccuring_event_id"], name: "index_tasks_on_reoccuring_event_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
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
  end

  add_foreign_key "comments", "tasks"
  add_foreign_key "file_attachments", "comments"
  add_foreign_key "file_attachments", "tasks"
  add_foreign_key "logged_labors", "tasks"
  add_foreign_key "logged_labors", "users"
  add_foreign_key "reoccuring_events", "reoccuring_event_types"
  add_foreign_key "reoccuring_events", "tasks"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users", column: "assigned_by_id"
  add_foreign_key "task_assignments", "users", column: "assigned_to_id"
  add_foreign_key "task_queues", "task_types"
  add_foreign_key "task_queues", "tasks"
  add_foreign_key "task_queues", "users"
  add_foreign_key "task_type_options", "task_types"
  add_foreign_key "tasks", "reoccuring_events"
  add_foreign_key "tasks", "users", column: "created_by_id"
end
