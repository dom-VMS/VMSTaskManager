# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User
user = User.create(employee_number: 999, f_name: 'System', l_name: 'Administrator', email: 'test@varland.com', password: 'Vms.1946!')

# Project -- Roles (TaskTypeOptions) and role-assignments (UserGroups) will be generated automatically.
task_type = TaskType.create(name: 'Sys. Admin', description: 'Use this project to add other users into the system.', parent_id: nil, created_by_id: user.id)

# Tasks
task = Task.create(title: 'Add Users into System', description: 'Find your way to /users/new and add users to Project Manager.', priority: 3, status: 1, percentComplete: 0,
                      task_type_id: task_type.id, isApproved: true, isVerified: nil, created_by_id: user.id, verification_required: false, logged_labor_required: false)

# Task Assignment
task_assignment = TaskAssignment.create(task_id: task.id, assigned_to_id: user.id, assigned_by_id: user.id)

