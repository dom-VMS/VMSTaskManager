class RenameTagTypeOptionIdToTaskTypeOptionId < ActiveRecord::Migration[5.1]
  def change
    rename_column :user_groups, :tag_type_option_id, :task_type_option_id
  end
end
