class TaskQueuesController < ApplicationController
  def index
    @user = User.find_by_id(task_queue_params[:user])
    @task_type = TaskType.find_by_id(task_queue_params[:task_type_id])
    @queue = TaskQueue.where(user_id: task_queue_params[:user], task_type_id: task_queue_params[:task_type_id]).
                       order(:position)
  end
  
  private
  def task_queue_params
    params.permit(:task_type_id, :user)
  end
end
