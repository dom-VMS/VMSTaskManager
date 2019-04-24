class TaskAssignmentsController < ApplicationController

    def new
        @task = Task.find_by_id(assignment_params[:task_id])
        @task_type = TaskType.find_by_id(@task.task_type_id)
        get_assignable_users
        @task_assignment = TaskAssignment.new
    end

    def create
        @task = Task.find_by_id(assignment_params[:task_id])
        TaskAssignment.create(assignment_params[:task_assignment])
        flash[:notice] = "Successfully added assignee."
        respond_to do |format|
            format.html { redirect_to task_path(@task, :param => 'edit') }
            format.js {render "tasks/form-small"}
        end
    end

    def update
    end

    def destroy
        @task = Task.find(params[:task_id])
        @assigment = @task.task_assignments.find(params[:id])
        @assigment.destroy
        flash[:notice] = "Successfully removed assignee."

        respond_to do |format|
            if params[:param] == 'edit'
                format.html { redirect_to task_path(@task, :param => 'edit')}
            else
                format.html { redirect_to task_path(@task)}
            end       
        end
    end

    private
    def assignment_params
        params.permit(:task_id, {task_assignment: [:assigned_to_id, :assigned_by_id, :task_id]})
    end

    # Retrieves all users that may be assigned to a task.
    def get_assignable_users
        @assignable_users = TaskType.get_users(@task_type) 
    end
       
end
