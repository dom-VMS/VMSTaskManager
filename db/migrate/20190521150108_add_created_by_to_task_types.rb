class AddCreatedByToTaskTypes < ActiveRecord::Migration[5.2]
  def change
    add_reference :task_types, :created_by, foreign_key: { to_table: :users }
  end
end
