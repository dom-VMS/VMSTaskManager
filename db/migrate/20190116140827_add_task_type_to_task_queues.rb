class AddTaskTypeToTaskQueues < ActiveRecord::Migration[5.1]
  def change
    add_reference :task_queues, :task_type, foreign_key: true
  end
end
