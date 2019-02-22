class TaskTypeOption < ApplicationRecord
  belongs_to :task_type
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  # Gets all @users associated with task_type_option via @user_groups
  # Params:
  # task_type_option -  An instance of the object @task_type_option.
  def self.get_associated_users(task_type_option)
    users = []

    user_group = (UserGroup.where(task_type_option_id: task_type_option.id)).all
    if !user_group.empty?
      user_group.each do |i|
        users.push(User.find_by_id(i.user_id))
      end
    end

    return users
  end

  # Some users belong to multiple task_types. Their associated TaskTypeOptions
  # may vary by TaskType. To ensure the current_user is granted their permissions
  # when visiting their TaskType page, call this method to grab that specific
  # set of TaskTypeOptions for a current_user. If user does not belong to said
  # task_type, then return nil.
  # Params:
  # current_user - current user in the session.
  # task_type_id - give the task_type_id associated with the task_type or task.
  def self.get_task_type_specific_options(current_user, task_type_id)
    (current_user.task_type_options).each do |i|
      if i.task_type_id == task_type_id
          return task_type_option = i 
      else
          task_type_option = nil
      end
    end
    
    return nil
  end

end
