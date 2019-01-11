class HomeController < ApplicationController
  def index
    if logged_in?
      task_type_ids = TaskType.get_task_types_assigned_to_user(current_user)
      @task_types = TaskType.where(id: [task_type_ids])
      @task = Task.get_all_tasks_assigned_to_user(current_user)
      @task_queue = TaskQueue.retrieve_tasks(current_user)
    else
      render partial: 'errors/not_signed_in'
    end
  end

  def ticket
  end
end
