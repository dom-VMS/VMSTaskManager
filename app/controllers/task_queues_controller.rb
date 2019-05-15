class TaskQueuesController < ApplicationController
  before_action :find_user
  before_action :find_task_type
  before_action :get_queue, only: [:index, :create]

  def index
    validate_current_user_can_view
    task_type = TaskType.find_by_id(task_queue_params[:task_type_id])
    @tasks = Task.get_tasks_assigned_to_user_for_task_type(task_type, @user)
  end
  
  def create
    if @queue.empty?
      task_queue = TaskQueue.new(task_queue_params.merge(:position => 0))
    else
      position = get_last_position + 1
      task_queue = TaskQueue.new(task_queue_params.merge(:position => position))
    end
    if task_queue.save!
      flash.now[:notice] = "Successfully added task to queue."
      redirect_to task_type_user_task_queues_path(task_queue_params[:task_type_id], task_queue_params[:user_id])
    else
      flash.now[:error] = "Failed to add task to queue."
      redirect_back(fallback_location: task_type_user_task_queues_path(task_queue_params[:task_type_id], task_queue_params[:user_id]))
    end
  end

  def destroy
    get_queue_item
    @queue.destroy
    respond_to do |format|
      flash.now[:notice] = "Successfully removed task from queue."
      format.html { redirect_back(fallback_location: task_type_user_task_queues_path(@task_type.id, @user.id))}
    end
  end

  private
  def task_queue_params
    params.permit(:task_type_id, :user_id, :task_id, :id)
  end

  def find_user
    @user = User.find_by_id(task_queue_params[:user_id])
  end

  def find_task_type
    @task_type = TaskType.find_by_id(task_queue_params[:task_type_id])
  end

  def get_queue
    @queue = @user.task_queues.where(task_type_id: @task_type.id).order(:position)
  end

  def get_queue_item
    @queue = TaskQueue.find_by_id(task_queue_params[:id])
  end

  def validate_current_user_can_view
    @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
    unless @task_type_option.nil? 
      if !(@task_type_option.isAdmin || current_user.id == @user.id)
        respond_to do |format|
          flash.now[:error] = "Sorry, but you are not permitted to view or edit this user's queue."
          format.html { redirect_back(fallback_location: task_type_path(@task_type)) }
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = "Sorry, but you are not permitted to view or edit this user's queue."
        format.html { redirect_back(fallback_location: task_type_path(@task_type)) }
      end
    end
  end
  
  def get_last_position
    get_queue
    last_element = @queue.last
    return last_element.position
  end
end
