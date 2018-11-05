class HomeController < ApplicationController
  def index
    user_group = current_user.user_groups
    @task_types = []
    user_group.each do |ug| 
      @task_types.push(TaskType.find_by_id(ug.task_type_option.task_type_id))
    end
  end

  def ticket
  end
end
