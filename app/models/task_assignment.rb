class TaskAssignment < ApplicationRecord
  include ActiveModel::Dirty
  
  before_update :remove_task_from_queue
  before_destroy :remove_task_from_queue

  belongs_to :task, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true, foreign_key: 'assigned_to_id'
  belongs_to :assigned_by, class_name: "User", optional: true, foreign_key: 'assigned_by_id'

  def self.get_assignee(task)
    assignee = []
    (task.task_assignments).each do |ta|
      if (ta.assigned_to).present?
        assignee.push(ta.assigned_to.full_name) 
      else 
        return ""
      end
    end
    
    return assignee
  end

  def self.get_assigned_user(task)
    TaskAssignment.where(task_id: task.id) 
  end

  def self.get_assigner(task)
    assigner = []
    (task.task_assignments).each do |ta|
      if (ta.assigned_by).present?
        assigner.push(ta.assigned_by.full_name) 
      else 
        return ""
      end
    end
    
    return assigner
  end

  # Removes a task belonging in a user's queue if the user is not longer assigned.
  def remove_task_from_queue
      queue_item = TaskQueue.find_by(task_id: task.id, user_id: assigned_to_id_was)
      queue_item.destroy unless queue_item.nil?
  end
end
