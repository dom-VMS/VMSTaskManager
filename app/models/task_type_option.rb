class TaskTypeOption < ApplicationRecord
  
  ## Active Record Associations
  belongs_to :task_type
  # has_many :through Association (users x user_groups x task_type_options)
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  ## Scopes
  scope :project, -> (task_type) { where(task_type_id: task_type) }
  
  # Finds the TaskTypeOption (Role) for a user given a TaskType (project).
  def self.get_task_type_specific_options(user, task_type)
    task_type_option = user.task_type_options.project(task_type)
    # In the case a user has multiple task_type_options for a task_type, see if any is an admin. If so, return that option.
    if task_type_option&.size > 1
      return task_type_option.where(isAdmin: true) if task_type_option.where(isAdmin: true).any?
    end
    return TaskTypeOption.find_by_id(task_type_option.pluck(:id)) unless task_type_option.empty?
    # No TaskTypeOption matching that User & TaskType was found. 
    if task_type.parent.present?
      # Iterate through the parent projects (if any) until there is a TaskTypeOption the user is assigned to.
      task_type_option = TaskTypeOption.get_task_type_specific_options(user, task_type.parent)
      return task_type_option unless task_type_option.nil?
    end
    # No TaskTypeOption could be found, return nil.
    return nil
  end

end
