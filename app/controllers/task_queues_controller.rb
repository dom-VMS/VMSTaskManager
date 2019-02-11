class TaskQueuesController < ApplicationController
  before_action :find_user
  before_action :find_task_type
  before_action :get_queue, only: [:index, :edit]

  def index
    task_type = TaskType.find_by_id(task_queue_params[:task_type_id])
    user = User.find_by_id(task_queue_params[:user_id])
    @tasks = Task.get_tasks_assigned_to_user_for_task_type(task_type, user)
  end
  
  def create
    get_queue
    if @queue.empty?
      task_queue = TaskQueue.new(task_queue_params.merge(:position => 0))
    else
      position = get_last_position + 1
      task_queue = TaskQueue.new(task_queue_params.merge(:position => position))
    end
    if task_queue.save!
      flash[:notice] = "Successfully added task to queue."
      redirect_to task_type_user_task_queues_path(task_queue_params[:task_type_id], task_queue_params[:user_id])
    else
      flash[:danger] = "Failed to add task to queue."
      redirect_to task_type_user_task_queues_path(task_queue_params[:task_type_id], task_queue_params[:user_id])
    end
  end

  private
  def task_queue_params
    params.permit(:task_type_id, :user_id, :task_id)
  end

  def find_user
    @user = User.find_by_id(task_queue_params[:user_id])
  end

  def find_task_type
    @task_type = TaskType.find_by_id(task_queue_params[:task_type_id])
  end

  def get_queue
    @queue = TaskQueue.where(user_id: task_queue_params[:user_id], task_type_id: task_queue_params[:task_type_id]).order(:position)
  end
  
  def get_last_position
    get_queue
    last_element = @queue.last
    return last_element.position
  end
end
