class ChnageUsersToUserInUserGroup < ActiveRecord::Migration[5.1]
  def change
    rename_column :user_groups, :users_id, :user_id
  end
end
