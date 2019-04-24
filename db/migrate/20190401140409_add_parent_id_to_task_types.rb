class AddParentIdToTaskTypes < ActiveRecord::Migration[5.2]
  def change
    add_reference :task_types, :parent, foreign_key: { to_table: :task_types }
  end
end
