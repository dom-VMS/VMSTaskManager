class TaskAssignment < ApplicationRecord
  belongs_to :task, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :assigned_by, class_name: "User", optional: true

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
end
