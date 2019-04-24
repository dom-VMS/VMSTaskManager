class HomeController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :welcome]

  def index
    task_type_ids = TaskType.get_task_types_assigned_to_user(current_user) 
    @task_types = TaskType.find(task_type_ids) 

    @task_types.each do |task_type|
      if task_type.children.any?
        task_type.children.each do |child|
          @task_types.append(child) unless (@task_types.any? {|task_type| task_type == child})
        end
      end
    end
    @task = Task.get_all_tasks_assigned_to_user(current_user)
  end

  def ticket
  end

  def welcome
  end
end
