class TaskAssignmentsController < ApplicationController

    def new
        @task = Task.find_by_id(assignment_params[:task_id])
        @task_type = TaskType.find_by_id(@task.task_type_id)
        @assignable_users = TaskType.get_users(@task_type) 
        @task_assignment = TaskAssignment.new
    end

    def create
        @task = Task.find_by_id(assignment_params[:task_id])
        TaskAssignment.create(assignment_params[:task_assignment])
        flash[:notice] = "Successfully added assignee."
        respond_to do |format|
            format.html { redirect_to task_path(@task, :param => 'edit') } # Renders the "Quick Edit" form
            format.js {render "tasks/form"}
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
            if params[:param] == 'edit' # This occurs if a user destroys a TaskAssignment from the quick edit form.
                format.html { redirect_to task_path(@task, :param => 'edit')} # Renders the "Quick Edit" form
            else
                format.html { redirect_to task_path(@task)}
            end       
        end
    end

    private
    def assignment_params
        params.permit(:task_id, {task_assignment: [:assigned_to_id, :assigned_by_id, :task_id]})
    end
end
