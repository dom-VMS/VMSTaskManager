class HomeController < ApplicationController
  def index
    if logged_in?
      user_group = current_user.user_groups
      @task_types = []
      user_group.each do |ug| 
        @task_types.push(TaskType.find_by_id(ug.task_type_option.task_type_id))
      end
    else
      render partial: 'errors/not_signed_in'
    end
  end

  def ticket
  end
end
