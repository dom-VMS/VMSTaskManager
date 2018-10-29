class ChangeTaskTypesIdToTaskTypeId < ActiveRecord::Migration[5.1]
  def change
    rename_column :tasks, :task_types_id, :task_type_id
  end
end
