class CreateTaskAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :task_assignments do |t|
      t.belongs_to :task, index: true, foreign_key: {to_table: :tasks}
      t.belongs_to :assigned_to, index: true, foreign_key: {to_table: :users}
      t.belongs_to :assigned_by, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
