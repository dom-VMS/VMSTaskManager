# I messed up the User_Group/Task_Type_Options_Users table pretty bad.
# Best to just roll back and restart.
class DropTaskTypeOptionsUsersTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :task_type_options_users 
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
