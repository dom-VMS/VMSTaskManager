class TaskTypeOption < ApplicationRecord
  belongs_to :task_type
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  # Some users belong to multiple task_types. Their associated TaskTypeOptions
  # may vary by TaskType. To ensure the user is granted their permissions
  # when visiting their TaskType page, call this method to grab that specific
  # set of TaskTypeOptions for a user. If the user does not belong to a given
  # task_type, search to see if that TaskType has a parent. If the user
  # has a TaskTypeOption there, return it. Keep repeating until you've found a TaskTypeOption or reached the top-most parent project.
  # If there is no TaskTypeOption that can be applied, return nil.
  # 
  # Params:
  # user - current user in the session.
  # task_type - task_type / project where a user is currently at.
  def self.get_task_type_specific_options(user, task_type)

    # Return the TaskTypeOption for a given TaskType & User (if it exsist)
    task_type_option = (user.task_type_options).where(task_type_id: task_type.id)
   
    # In the case a user has multiple task_type_options for a task_type, see if any of them is an admin. If so, return that option.
    if task_type_option&.size > 1
      return TaskTypeOption.find_by_id(task_type_option.where(isAdmin: true).pluck(:id)) if task_type_option.where(isAdmin: true).any?
    end
    
    return TaskTypeOption.find_by_id(task_type_option.pluck(:id)) unless task_type_option.empty?

    # No TaskTypeOption matching that User & TaskType was found.
    # Find the parent project (if any) and see if there is a match.
    if task_type.parent.present?
      task_type_option = TaskTypeOption.get_task_type_specific_options(user, task_type.parent)
      return task_type_option unless task_type_option.nil?
    end

    # No TaskTypeOption could be found, return nil.
    return nil

  end

  # Params:
  # user - current user in the session.
  def self.get_user_task_types(user)
    tto = user.task_type_options #Grab the current user's role(s).
    return nil if tto.empty?

    user_task_types = tto.pluck(:task_type_id) #Returns projects the user belongs to.
    puts user_task_types
  end

end
