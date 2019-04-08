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
  # set of TaskTypeOptions for a current_user. If the user does not belong to a given
  # task_type, search to see if that TaskType has a parent. If the user
  # has a TaskTypeOption there, return it. Keep repeating until you've found a TaskTypeOption or reached the top-most parent project.
  # If there is no TaskTypeOption that can be applied, return nil.
  # 
  # Params:
  # current_user - current user in the session.
  # task_type - task_type / project where a user is currently at.
  def self.get_task_type_specific_options(current_user, task_type)

    # Return the TaskTypeOption for a given TaskType & User (if it exsist)
    task_type_option = (current_user.task_type_options).where(task_type_id: task_type.id)
    return TaskTypeOption.find_by_id(task_type_option.pluck(:id)) unless task_type_option.empty?

    # No TaskTypeOption matching that User & TaskType was found.
    # Find the parent project (if any) and see if there is a match.
    if task_type.parent.present?
      task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, task_type.parent)
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
