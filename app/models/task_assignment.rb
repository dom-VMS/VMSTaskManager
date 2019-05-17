class TaskAssignment < ApplicationRecord
  include ActiveModel::Dirty
  
  ## Active Record Callbacks
  before_update :remove_task_from_queue
  before_destroy :remove_task_from_queue

  ## Active Record Associations 
  belongs_to :task, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true, foreign_key: 'assigned_to_id'
  belongs_to :assigned_by, class_name: "User", optional: true, foreign_key: 'assigned_by_id'

  ## Active Record Validations
  validate :assignee_must_be_in_project

  # Validates that the user assigned to a task is a member of the project (or related project)
  def assignee_must_be_in_project
    assignee = User.find_by_id(assigned_to_id)
    unless assignee.nil?
      task = Task.find_by_id(task_id)
      task_type = task.task_type
      unless TaskTypeOption.get_task_type_specific_options(assignee, task_type).present?
        errors.add(:assigned_to, "must belong to this project before being assigned to this task.")
      end
    end
  end

  # Removes a task belonging in a user's queue if the user is not longer assigned.
  def remove_task_from_queue
      queue_item = TaskQueue.find_by(task_id: task.id, user_id: assigned_to_id_was)
      queue_item.destroy unless queue_item.nil?
  end
end
