class HomeController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :welcome]

  def index
    # Get all tasks assigned to the current user
    @task = Task.get_all_tasks_assigned_to_user(current_user).includes(:task_type)

    # Find TaskTypes based on the task_type_id's of the tasks assigned to the user.
    @task_types = TaskType.project(@task.pluck(:task_type_id).uniq).order(:parent_id) 
  end

  def ticket
  end

  def welcome
  end
end
