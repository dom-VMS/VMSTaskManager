class TaskTypeOption < ApplicationRecord
  belongs_to :task_type
  has_many :user_groups
  has_many :users, through: :user_groups

  # Runs a process to find the related @task_type_option(s) when provided a @user_group.
  # Params:
  # user_group - An instance of the object @user_group.
  def self.find_by_user_group(user_group)
    task_type_option = []
    user_group.each do |i|
      task_type_option.push(TaskTypeOption.find_by_id(i.task_type_option_id))
    end

    return task_type_option
  end

  # Gets @task_type.name of any task_type related to a provided @task_type_option
  # Params:
  # +task_type_option+:: An instance of the object @task_type_option.
  def self.get_task_type_name(task_type_option)
    task_type_id_search = task_type_option.task_type_id
    task_type_name = (TaskType.find_by_id(task_type_id_search)).name

    return task_type_name
  end

end
