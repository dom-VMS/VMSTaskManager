class TaskAssignment < ApplicationRecord
  include ActiveModel::Dirty
  
  before_update :remove_task_from_queue
  before_destroy :remove_task_from_queue

  belongs_to :task, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true, foreign_key: 'assigned_to_id'
  belongs_to :assigned_by, class_name: "User", optional: true, foreign_key: 'assigned_by_id'

  # Removes a task belonging in a user's queue if the user is not longer assigned.
  def remove_task_from_queue
      queue_item = TaskQueue.find_by(task_id: task.id, user_id: assigned_to_id_was)
      queue_item.destroy unless queue_item.nil?
  end
end
