class HomeController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :welcome]

  def index
      task_type_ids = TaskType.get_task_types_assigned_to_user(current_user)
      @task_types = TaskType.where(id: [task_type_ids])
      @task = Task.get_all_tasks_assigned_to_user(current_user)
  end

  def ticket
  end

  def welcome
  end
end
