class HomeController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :welcome]

  def index
    @task = Task.get_all_tasks_assigned_to_user(current_user)
    @task_types = TaskType.where(id: @task.pluck(:task_type_id).uniq).order(:parent_id)
    #@task_types_mobile = TaskTypes.all
  end

  def ticket
  end

  def welcome
  end
end
