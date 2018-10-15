class ChangeUserGroupsTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :user_groups, :task_type_options_users #Renames because User_Group was supposed to be a Join Table. This name will help Rails work it's magic.
  end
end
